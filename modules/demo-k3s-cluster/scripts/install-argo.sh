#!/bin/bash

LOG_FILE="/tmp/argo-install.log"
exec > >(tee -a ${LOG_FILE})
exec 2>&1

set -e

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log "=== Starting Argo Workflows installation ==="

# Wait for k3s to be fully ready
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

log "Step 5: Configuring Argo server for no-auth mode and HTTP readiness probe"
# Check if already patched by looking for insecure args
if kubectl get deployment argo-server -n argo -o jsonpath='{.spec.template.spec.containers[0].args}' | grep -q "secure=false"; then
    log "Argo server already configured for no-auth mode"
else
    log "Patching Argo server for no-auth mode..."
    kubectl patch deployment argo-server -n argo --patch '{"spec":{"template":{"spec":{"containers":[{"name":"argo-server","args":["server","--auth-mode=server","--secure=false"],"readinessProbe":{"httpGet":{"scheme":"HTTP","path":"/","port":2746}}}]}}}}'
fi

log "Step 6: Waiting for deployment to be ready"
kubectl rollout status deployment/argo-server -n argo --timeout=300s

log "Step 7: Setting up RBAC permissions for workflows"
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

log "Step 8: Creating ingress for Argo UI"
if kubectl get ingress argo-server -n argo >/dev/null 2>&1; then
    log "Ingress already exists, skipping creation"
else
    log "Creating ingress for Argo UI..."
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
  - host: argo.$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4).nip.io
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

log "Step 9: Verifying installation"
kubectl get pods -n argo
kubectl get svc -n argo
kubectl get ingress -n argo

log "Step 10: Creating test workflow (if none exist)"
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
log "Installation logs are available at: ${LOG_FILE}"
log "You can view logs with: cat ${LOG_FILE}"
log ""
log "=== Available Tools ==="
log "- kubectl: Standard Kubernetes CLI"
log "- k9s: Terminal-based Kubernetes UI (just run 'k9s')"
log "- Argo UI: Web-based workflow management"
