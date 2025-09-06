variable "agent_hub_webhook_github_token" {
  description = "GitHub token for agent-hub webhook responses"
  type        = string
  sensitive   = true
}

variable "github_management_token" {
  description = "GitHub token for Terraform to manage repositories and settings"
  type        = string
  sensitive   = true
}