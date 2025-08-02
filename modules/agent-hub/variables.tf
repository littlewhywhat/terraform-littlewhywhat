variable "codedeploy_service_role_arn" {
  description = "ARN of the CodeDeploy service role"
  type        = string
}

variable "agent_hub_ssh_public_key" {
  description = "SSH public key for agent-hub EC2 access"
  type        = string
}