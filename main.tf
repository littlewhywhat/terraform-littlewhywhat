module "ec2_service" {
  source = "./modules/ec2-service"
}

module "agent_hub" {
  source = "./modules/agent-hub"
  codedeploy_service_role_arn        = module.code-deploy.codedeploy_role_arn
  agent_hub_ssh_public_key           = var.agent_hub_ssh_public_key
  amazon_linux_ami_id                = module.ec2_service.amazon_linux_ami_id
  ec2_service_security_group_id      = module.ec2_service.ec2_service_security_group_id
  agent_hub_webhook_github_token     = var.agent_hub_webhook_github_token
}

module "code-deploy" {
  source = "./modules/code-deploy"
}

output "agent_hub_ssh_command" {
  description = "SSH command to connect to agent-hub instance"
  value       = "ssh -i /path/to/your/private/key ec2-user@${module.agent_hub.agent_hub_public_ip}"
}

output "github_access_key_id" {
  description = "GitHub IAM access key ID"
  value       = module.agent_hub.github_access_key_id
}

output "github_secret_access_key" {
  description = "GitHub IAM secret access key"
  value       = module.agent_hub.github_secret_access_key
  sensitive   = true
}

output "webhook_github_token_secret_arn" {
  description = "ARN of the agent-hub webhook GitHub token secret"
  value       = module.agent_hub.webhook_github_token_secret_arn
}

output "webhook_github_token_secret_name" {
  description = "Name of the agent-hub webhook GitHub token secret - use this to set the secret value"
  value       = module.agent_hub.webhook_github_token_secret_name
}

output "webhook_github_token_get_command" {
  description = "Command to retrieve the agent-hub webhook GitHub token secret value"
  value       = "aws secretsmanager get-secret-value --secret-id ${module.agent_hub.webhook_github_token_secret_name} --query SecretString --output text"
}

output "webhook_github_token_set_command" {
  description = "Command to set the agent-hub webhook GitHub token secret value (replace YOUR_TOKEN)"
  value       = "aws secretsmanager put-secret-value --secret-id ${module.agent_hub.webhook_github_token_secret_name} --secret-string 'YOUR_TOKEN'"
}
