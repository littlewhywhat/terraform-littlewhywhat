output "agent_hub_public_ip" {
  description = "Public IP address of the agent-hub EC2 instance"
  value       = aws_instance.agent_hub.public_ip
}

output "agent_hub_instance_id" {
  description = "Instance ID of the agent-hub EC2 instance"
  value       = aws_instance.agent_hub.id
}

output "github_access_key_id" {
  value = aws_iam_access_key.github_agent_hub_key.id
}

output "github_secret_access_key" {
  value     = aws_iam_access_key.github_agent_hub_key.secret
  sensitive = true
}

output "webhook_github_token_secret_arn" {
  description = "ARN of the agent-hub webhook GitHub token secret"
  value       = aws_secretsmanager_secret.webhook_github_token.arn
}

output "webhook_github_token_secret_name" {
  description = "Name of the agent-hub webhook GitHub token secret"
  value       = aws_secretsmanager_secret.webhook_github_token.name
}
