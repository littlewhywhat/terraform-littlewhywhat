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
kubectl create namespace argo || echo "Namespace argo already exists"

log "Step 3: Installing Argo Workflows"
kubectl apply -n argo -f https://github.com/argoproj/argo-workflows/releases/download/v3.7.1/install.yaml

log "Step 4: Waiting for Argo Workflows pods to be ready"
kubectl wait --for=condition=available deployment/argo-server -n argo --timeout=300s
kubectl wait --for=condition=available deployment/workflow-controller -n argo --timeout=300s

log "Step 5: Configuring Argo server for no-auth mode and HTTP readiness probe"
kubectl patch deployment argo-server -n argo --patch '{"spec":{"template":{"spec":{"containers":[{"name":"argo-server","args":["server","--auth-mode=server","--secure=false"],"readinessProbe":{"httpGet":{"scheme":"HTTP","path":"/","port":2746}}}]}}}}'

log "Step 6: Waiting for patched deployment to be ready"
kubectl rollout status deployment/argo-server -n argo --timeout=300s

log "Step 7: Creating ingress for Argo UI"
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

log "Step 8: Verifying installation"
kubectl get pods -n argo
kubectl get svc -n argo
kubectl get ingress -n argo

log "Step 9: Creating test workflow"
cat <<EOF | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: hello-world-
  namespace: argo
spec:
  entrypoint: whalesay
  templates:
  - name: whalesay
    container:
      image: docker/whalesay
      command: [cowsay]
      args: ["Hello World from Argo!"]
EOF

log "=== Argo Workflows installation completed successfully ==="
log "Access Argo UI at: http://argo.$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4).nip.io"
log "Installation logs are available at: ${LOG_FILE}"
