module "ec2_service" {
  source = "./modules/ec2-service"
}

module "code-deploy" {
  source = "./modules/code-deploy"
}

output "github_management_token" {
  description = "GitHub management token"
  value       = var.github_management_token
  sensitive   = true
}
