resource "aws_secretsmanager_secret" "webhook_github_token" {
  name        = "agent-hub/webhook-github-token"
  description = "GitHub token for agent-hub webhook responses"
  
  tags = {
    Environment = "production"
    Service     = "agent-hub"
    Purpose     = "webhook"
  }
}

resource "aws_secretsmanager_secret_version" "webhook_github_token" {
  secret_id     = aws_secretsmanager_secret.webhook_github_token.id
  secret_string = var.agent_hub_webhook_github_token
}