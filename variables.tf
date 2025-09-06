variable "aws_access_key" {
  description = "AWS access key"
  type        = string
  sensitive   = true
}

variable "aws_secret_key" {
  description = "AWS secret key"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "github_management_token" {
  description = "GitHub token for Terraform to manage repositories and settings"
  type        = string
  sensitive   = true
}

# variable "agent_hub_ssh_public_key" {
#   description = "SSH public key for agent-hub EC2 access"
#   type        = string
# }

# variable "agent_hub_webhook_github_token" {
#   description = "GitHub token for agent-hub webhook responses"
#   type        = string
#   sensitive   = true
# }
