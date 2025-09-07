module "demo_k3s_cluster" {
  source = "./modules/demo-k3s-cluster"

  demo_k3s_cluster_ssh_public_key = var.demo_k3s_cluster_ssh_public_key
  ubuntu_ami_id                   = module.ec2_service.ubuntu_ami_id
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
