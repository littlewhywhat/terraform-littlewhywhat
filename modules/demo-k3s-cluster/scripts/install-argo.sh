#!/bin/bash

LOG_FILE="/tmp/argo-install.log"
exec > >(tee -a ${LOG_FILE})
exec 2>&1

set -e

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Use ubuntu user's kubeconfig instead of root's
export KUBECONFIG=/home/ubuntu/.kube/config

log "=== Starting Argo Workflows installation ==="

log "Step 1: Checking if k3s is ready"
if kubectl wait --for=condition=ready nodes --all --timeout=5s >/dev/null 2>&1; then
    log "k3s is already ready, proceeding..."
else
    log "k3s not ready yet, waiting 30 seconds..."
    sleep 30
    log "Now waiting for k3s nodes to be ready..."
    kubectl wait --for=condition=ready nodes --all --timeout=300s
fi

log "Step 2: Creating argo namespace"
kubectl create namespace argo 2>/dev/null || echo "Namespace argo already exists"

log "Step 3: Installing Argo Workflows"
if kubectl get deployment argo-server -n argo >/dev/null 2>&1; then
    log "Argo Workflows already installed, skipping installation"
else
    log "Installing Argo Workflows..."
    kubectl apply -n argo -f https://github.com/argoproj/argo-workflows/releases/download/v3.7.1/install.yaml
fi

log "Step 4: Waiting for Argo Workflows pods to be ready"
kubectl wait --for=condition=available deployment/argo-server -n argo --timeout=300s
kubectl wait --for=condition=available deployment/workflow-controller -n argo --timeout=300s

log "Step 5: Configuring Argo server for token-based auth"
CURRENT_ARGS=$(kubectl get deployment argo-server -n argo -o jsonpath='{.spec.template.spec.containers[0].args}')
if echo "$CURRENT_ARGS" | grep -q "auth-mode=client" && echo "$CURRENT_ARGS" | grep -q "secure=false"; then
    log "Argo server already configured for HTTP + token auth"
elif echo "$CURRENT_ARGS" | grep -q "auth-mode=client"; then
    log "Found HTTPS token config, switching to HTTP + token auth..."
    kubectl patch deployment argo-server -n argo --patch '{"spec":{"template":{"spec":{"containers":[{"name":"argo-server","args":["server","--auth-mode=client","--secure=false"]}]}}}}'
else
    log "Patching Argo server for HTTP + token-based authentication..."
    kubectl patch deployment argo-server -n argo --patch '{"spec":{"template":{"spec":{"containers":[{"name":"argo-server","args":["server","--auth-mode=client","--secure=false"]}]}}}}'
fi

log "Step 6: Waiting for deployment to be ready"
kubectl rollout status deployment/argo-server -n argo --timeout=300s

log "Step 7: Setting up admin user and token"
if kubectl get serviceaccount argo-admin -n argo >/dev/null 2>&1; then
    log "Admin user already exists, checking bindings..."
else
    log "Creating admin user..."
    kubectl create serviceaccount argo-admin -n argo
fi

log "Setting up RBAC for admin user and argo-server..."
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: argo-admin-cluster-role
rules:
- apiGroups: [""]
  resources: ["*"]
  verbs: ["*"]
- apiGroups: ["apps"]
  resources: ["*"]
  verbs: ["*"]
- apiGroups: ["argoproj.io"]
  resources: ["*"]
  verbs: ["*"]
- apiGroups: ["networking.k8s.io"]
  resources: ["*"]
  verbs: ["*"]
- apiGroups: ["rbac.authorization.k8s.io"]
  resources: ["*"]
  verbs: ["*"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: argo-admin-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: argo-admin-cluster-role
subjects:
- kind: ServiceAccount
  name: argo-admin
  namespace: argo
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: argo-server-cluster-role
rules:
- apiGroups: [""]
  resources: ["configmaps", "events"]
  verbs: ["get", "watch", "list"]
- apiGroups: [""]
  resources: ["pods", "pods/exec", "pods/log"]
  verbs: ["get", "list", "watch", "delete"]
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get", "list", "watch"]
- apiGroups: [""]
  resources: ["serviceaccounts"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["argoproj.io"]
  resources: ["workflows", "workflowtemplates", "cronworkflows", "clusterworkflowtemplates", "workflowtaskresults", "workflowtasksets"]
  verbs: ["create", "get", "list", "watch", "update", "patch", "delete"]
- apiGroups: [""]
  resources: ["serviceaccounts/token"]
  verbs: ["create"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: argo-server-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: argo-server-cluster-role
subjects:
- kind: ServiceAccount
  name: argo-server
  namespace: argo
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: argo-admin-to-server-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: argo-server-cluster-role
subjects:
- kind: ServiceAccount
  name: argo-admin
  namespace: argo
EOF

log "Generating admin token..."
ADMIN_TOKEN=$(kubectl create token argo-admin -n argo --duration=8760h)
echo "$ADMIN_TOKEN" > /tmp/argo-admin-token.txt
log "Admin token saved to /tmp/argo-admin-token.txt"

log "Step 8: Setting up RBAC permissions for workflows"
if kubectl get serviceaccount argo-workflow -n argo >/dev/null 2>&1; then
    log "RBAC already configured, skipping setup"
else
    log "Creating RBAC permissions..."
    cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: argo-workflow
  namespace: argo
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: argo-workflow-role
  namespace: argo
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "watch", "patch"]
- apiGroups: [""]
  resources: ["pods/log"]
  verbs: ["get", "watch"]
- apiGroups: ["argoproj.io"]
  resources: ["workflows", "workflowtaskresults"]
  verbs: ["get", "watch", "patch", "create"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: argo-workflow-binding
  namespace: argo
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: argo-workflow-role
subjects:
- kind: ServiceAccount
  name: default
  namespace: argo
- kind: ServiceAccount
  name: argo-workflow
  namespace: argo
EOF
fi

log "Step 9: Creating/updating ingress for Argo UI"
CURRENT_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
EXPECTED_HOST="argo.${CURRENT_IP}.nip.io"

if kubectl get ingress argo-server -n argo >/dev/null 2>&1; then
    # Ingress exists, check if it has the correct IP
    INGRESS_HOST=$(kubectl get ingress argo-server -n argo -o jsonpath='{.spec.rules[0].host}')
    if [ "$INGRESS_HOST" = "$EXPECTED_HOST" ]; then
        log "Ingress already exists with correct IP ($CURRENT_IP), skipping update"
    else
        log "Ingress exists but has wrong IP (expected: $EXPECTED_HOST, found: $INGRESS_HOST)"
        log "Updating ingress with current IP..."
        kubectl delete ingress argo-server -n argo
        log "Creating new ingress for Argo UI with IP $CURRENT_IP..."
        cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: argo-server
  namespace: argo
  annotations:
    traefik.ingress.kubernetes.io/router.entrypoints: web
spec:
  rules:
  - host: ${EXPECTED_HOST}
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: argo-server
            port:
              number: 2746
EOF
    fi
else
    log "Creating new ingress for Argo UI with IP $CURRENT_IP..."
    cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: argo-server
  namespace: argo
  annotations:
    traefik.ingress.kubernetes.io/router.entrypoints: web
spec:
  rules:
  - host: ${EXPECTED_HOST}
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: argo-server
            port:
              number: 2746
EOF
fi

log "Ingress configured for: http://${EXPECTED_HOST}"

log "Step 10: Verifying installation"
kubectl get pods -n argo
kubectl get svc -n argo
kubectl get ingress -n argo

log "Step 11: Creating test workflow (if none exist)"
# Check if any workflows exist (completed or running)
if kubectl get workflows -n argo 2>/dev/null | grep -q hello-world; then
    log "Test workflows already exist, skipping creation"
else
    log "Creating test workflow..."
    cat <<EOF | kubectl create -f -
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: hello-world-
  namespace: argo
spec:
  entrypoint: hello
  templates:
  - name: hello
    container:
      image: alpine:latest
      command: [sh, -c]
      args: ["echo '🎉 Hello from Argo Workflows! 🚀'; echo 'This workflow is working perfectly!'"]
  serviceAccountName: argo-workflow
EOF
fi

log "=== Argo Workflows installation completed successfully ==="
log "Access Argo UI at: http://argo.$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4).nip.io"
log ""
log "=== LOGIN INFORMATION ==="
log "Authentication: Token-based"
log "Username: argo-admin"
log "Token saved at: /tmp/argo-admin-token.txt"
log ""
log "Installation logs are available at: ${LOG_FILE}"
log "You can view logs with: cat ${LOG_FILE}"
log ""
log "=== Available Tools ==="
log "- kubectl: Standard Kubernetes CLI"
log "- k9s: Terminal-based Kubernetes UI (just run 'k9s')"
log "- Argo UI: Web-based workflow management (requires token login)"