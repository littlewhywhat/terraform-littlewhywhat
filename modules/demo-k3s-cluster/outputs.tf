output "public_ip" {
  description = "Public IP of the demo k3s cluster node"
  value       = aws_instance.demo_k3s_cluster.public_ip
}

output "ssh_command" {
  description = "SSH command to connect to the demo k3s cluster"
  value       = "ssh -i ~/.ssh/demo-k3s-cluster-key ubuntu@${aws_instance.demo_k3s_cluster.public_ip}"
}

output "argo_ui_url" {
  description = "URL to access Argo Workflows UI"
  value       = "http://argo.${aws_instance.demo_k3s_cluster.public_ip}.nip.io"
  depends_on  = [null_resource.install_argo]
}
