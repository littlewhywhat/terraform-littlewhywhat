variable "demo_k3s_cluster_ssh_public_key" {
  description = "SSH public key for demo k3s cluster access"
  type        = string
}

variable "ubuntu_ami_id" {
  description = "ID of the Ubuntu AMI"
  type        = string
}
