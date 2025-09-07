#!/bin/bash

LOG_FILE="/var/log/user-data.log"
exec > >(tee -a ${LOG_FILE})
exec 2>&1

set -e

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log "=== Starting k3s user-data script (Ubuntu) ==="

log "Step 1: Updating system packages"
apt-get update
apt-get upgrade -y

log "Step 2: Installing k3s"
curl -sfL https://get.k3s.io | sh -

log "Step 3: Installing k9s (Kubernetes terminal UI)"
if command -v k9s >/dev/null 2>&1; then
    log "k9s already installed, skipping..."
else
    log "Installing k9s..."
    # Get latest k9s version
    K9S_VERSION=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    
    # Download and install k9s
    wget -q "https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_amd64.tar.gz" -O /tmp/k9s.tar.gz
    tar -xzf /tmp/k9s.tar.gz -C /tmp
    sudo mv /tmp/k9s /usr/local/bin/
    sudo chmod +x /usr/local/bin/k9s
    rm -f /tmp/k9s.tar.gz /tmp/LICENSE /tmp/README.md
    
    log "k9s installed successfully: $(k9s version --short 2>/dev/null || echo 'version check failed')"
fi

log "Step 4: Starting k3s service"
systemctl start k3s

log "Step 5: Enabling k3s to start on boot"
systemctl enable k3s

log "Step 6: Setting up kubeconfig permissions for ubuntu user"
chmod 644 /etc/rancher/k3s/k3s.yaml

log "Step 7: Creating .kube directory for ubuntu user"
mkdir -p /home/ubuntu/.kube

log "Step 8: Copying kubeconfig to ubuntu user home"
cp /etc/rancher/k3s/k3s.yaml /home/ubuntu/.kube/config

log "Step 9: Setting ownership of kubeconfig"
chown ubuntu:ubuntu /home/ubuntu/.kube/config

export KUBECONFIG=/home/ubuntu/.kube/config

log "Step 10: Waiting for k3s to be ready"
sleep 30

log "Step 11: Checking k3s status"
systemctl status k3s

log "=== k3s user-data script completed successfully ==="
log "Logs are available at: ${LOG_FILE}"