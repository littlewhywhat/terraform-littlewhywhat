module "argo_configs" {
  source = "./modules/argo-configs"
}

output "argo_configs_github_repository_name" {
  description = "Name of the GitHub repository"
  value       = module.argo_configs.github_repository_name
}

module "demo_k3s_cluster" {
  source = "./modules/demo-k3s-cluster"
  
  demo_k3s_cluster_ssh_public_key = var.demo_k3s_cluster_ssh_public_key
  ubuntu_ami_id                   = module.ec2_service.ubuntu_ami_id
  
  demo_coding_agent_gitlab_token          = var.demo_coding_agent_gitlab_token
  demo_coding_agent_gitlab_webhook_secret = var.demo_coding_agent_gitlab_webhook_secret
  demo_coding_agent_cursor_token          = var.demo_coding_agent_cursor_token
  demo_coding_agent_gitlab_project_id     = var.demo_coding_agent_gitlab_project_id
  demo_coding_agent_gitlab_username       = var.demo_coding_agent_gitlab_username
  demo_coding_agent_gitlab_email          = var.demo_coding_agent_gitlab_email
}

output "demo_k3s_cluster_ssh_command" {
  description = "SSH command to connect to demo k3s cluster"
  value       = "ssh -i ~/.ssh/demo-k3s-cluster-key ubuntu@${module.demo_k3s_cluster.public_ip}"
}

output "demo_k3s_cluster_public_ip" {
  description = "Public IP of demo k3s cluster"
  value       = module.demo_k3s_cluster.public_ip
}

output "argo_workflows_ui" {
  description = "URL to access Argo Workflows UI in browser"
  value       = module.demo_k3s_cluster.argo_ui_url
}

output "argo_admin_token" {
  description = "Admin token for Argo Workflows UI - copy this to login"
  value       = module.demo_k3s_cluster.argo_admin_token
  sensitive   = true
}