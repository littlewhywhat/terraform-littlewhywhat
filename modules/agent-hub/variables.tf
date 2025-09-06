variable "codedeploy_service_role_arn" {
  description = "ARN of the CodeDeploy service role"
  type        = string
}

variable "agent_hub_ssh_public_key" {
  description = "SSH public key for agent-hub EC2 access"
  type        = string
}

variable "amazon_linux_ami_id" {
  description = "ID of the Amazon Linux AMI"
  type        = string
}

variable "ec2_service_security_group_id" {
  description = "ID of the EC2 service security group"
  type        = string
}

variable "agent_hub_webhook_github_token" {
  description = "GitHub token for agent-hub webhook responses"
  type        = string
  sensitive   = true
}
