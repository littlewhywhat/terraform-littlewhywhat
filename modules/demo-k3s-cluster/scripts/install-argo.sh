#!/bin/bash

LOG_FILE="/var/log/argo-install.log"
exec > >(tee -a ${LOG_FILE})
exec 2>&1

set -e

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log "=== Starting Argo Workflows installation ==="

# Wait for k3s to be fully ready
log "Step 1: Waiting for k3s to be ready"
sleep 30
kubectl wait --for=condition=ready nodes --all --timeout=300s

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

log "Step 7: Creating ingress for Argo UI"
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

log "Step 8: Verifying installation"
kubectl get pods -n argo
kubectl get svc -n argo
kubectl get ingress -n argo

log "Step 9: Creating test workflow (if none exist)"
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
EOF
fi

log "=== Argo Workflows installation completed successfully ==="
log "Access Argo UI at: http://argo.$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4).nip.io"
log "Installation logs are available at: ${LOG_FILE}"
