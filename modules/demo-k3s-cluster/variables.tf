variable "demo_k3s_cluster_ssh_public_key" {
  description = "SSH public key for demo k3s cluster access"
  type        = string
}

variable "ubuntu_ami_id" {
  description = "ID of the Ubuntu AMI"
  type        = string
}

variable "demo_coding_agent_gitlab_token" {
  description = "GitLab personal access token for demo coding agent"
  type        = string
  sensitive   = true
}

variable "demo_coding_agent_gitlab_webhook_secret" {
  description = "GitLab webhook secret token for demo coding agent"
  type        = string
  sensitive   = true
}

variable "demo_coding_agent_cursor_token" {
  description = "Cursor CLI token for demo coding agent"
  type        = string
  sensitive   = true
}

variable "demo_coding_agent_gitlab_project_id" {
  description = "GitLab project ID for demo coding agent webhooks"
  type        = string
}

variable "demo_coding_agent_gitlab_username" {
  description = "GitLab username for demo coding agent container registry"
  type        = string
}

variable "demo_coding_agent_gitlab_email" {
  description = "GitLab email for demo coding agent container registry"
  type        = string
}
