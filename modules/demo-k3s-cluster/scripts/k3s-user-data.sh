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

log "Step 3: Starting k3s service"
systemctl start k3s

log "Step 4: Enabling k3s to start on boot"
systemctl enable k3s

log "Step 5: Setting up kubeconfig permissions for ubuntu user"
chmod 644 /etc/rancher/k3s/k3s.yaml

log "Step 6: Creating .kube directory for ubuntu user"
mkdir -p /home/ubuntu/.kube

log "Step 7: Copying kubeconfig to ubuntu user home"
cp /etc/rancher/k3s/k3s.yaml /home/ubuntu/.kube/config

log "Step 8: Setting ownership of kubeconfig"
chown ubuntu:ubuntu /home/ubuntu/.kube/config

log "Step 9: Waiting for k3s to be ready"
sleep 30

log "Step 10: Checking k3s status"
systemctl status k3s

log "=== k3s user-data script completed successfully ==="
log "Logs are available at: ${LOG_FILE}"