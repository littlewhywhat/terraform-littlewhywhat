output "agent_hub_public_ip" {
  description = "Public IP address of the agent-hub EC2 instance"
  value       = aws_instance.agent_hub.public_ip
}

output "agent_hub_instance_id" {
  description = "Instance ID of the agent-hub EC2 instance"
  value       = aws_instance.agent_hub.id
}