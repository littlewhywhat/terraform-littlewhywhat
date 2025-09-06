output "public_ip" {
  description = "Public IP of the demo k3s cluster node"
  value       = aws_instance.demo_k3s_cluster.public_ip
}

output "ssh_command" {
  description = "SSH command to connect to the demo k3s cluster"
  value       = "ssh -i ~/.ssh/demo-k3s-cluster-key ec2-user@${aws_instance.demo_k3s_cluster.public_ip}"
}
