#!/bin/bash

# Setup logging
LOG_FILE="/var/log/user-data.log"
exec > >(tee -a ${LOG_FILE})
exec 2>&1

# Exit on any error
set -e

# Function to log with timestamp
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log "=== Starting user-data script ==="

log "Step 1: Updating system packages"
yum update -y

log "Step 2: Installing required packages (ruby, wget, python3, git, docker)"
yum install -y ruby wget python3 git docker

log "Step 3: Changing to ec2-user home directory"
cd /home/ec2-user

log "Step 4: Downloading CodeDeploy agent installer"
wget https://aws-codedeploy-us-east-1.s3.us-east-1.amazonaws.com/latest/install

log "Step 5: Setting execute permissions on installer"
chmod +x ./install

log "Step 6: Installing CodeDeploy agent"
./install auto

log "Step 7: Starting CodeDeploy agent service"
systemctl start codedeploy-agent

log "Step 8: Enabling CodeDeploy agent to start on boot"
systemctl enable codedeploy-agent

log "Step 9: Starting Docker service"
systemctl start docker

log "Step 10: Enabling Docker to start on boot"
systemctl enable docker

log "Step 11: Adding ec2-user to docker group"
usermod -a -G docker ec2-user

log "Step 12: Configuring AWS CLI region for ec2-user"
REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/region 2>/dev/null)
sudo -u ec2-user aws configure set default.region $REGION

log "=== User-data script completed successfully ==="
log "Logs are available at: ${LOG_FILE}"