module "ec2_service" {
  source = "./modules/ec2-service"
}

module "agent_hub" {
  source = "./modules/agent-hub"
  codedeploy_service_role_arn            = module.code-deploy.codedeploy_role_arn
  agent_hub_ssh_public_key               = var.agent_hub_ssh_public_key
  amazon_linux_ami_id                    = module.ec2_service.amazon_linux_ami_id
  ec2_service_security_group_id          = module.ec2_service.ec2_service_security_group_id
  agent_hub_webhook_github_token         = var.agent_hub_webhook_github_token
  github_management_token                = var.github_management_token
}

module "code-deploy" {
  source = "./modules/code-deploy"
}

output "agent_hub_ssh_command" {
  description = "SSH command to connect to agent-hub instance"
  value       = "ssh -i /path/to/your/private/key ec2-user@${module.agent_hub.agent_hub_public_ip}"
}

output "webhook_github_token_secret_name" {
  description = "Name of the agent-hub webhook GitHub token secret - use this to set the secret value"
  value       = module.agent_hub.webhook_github_token_secret_name
}
