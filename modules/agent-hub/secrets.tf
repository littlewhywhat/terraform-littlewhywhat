resource "aws_secretsmanager_secret" "github_token" {
  name        = "agent-hub/github-token"
  description = "GitHub token for agent-hub webhook responses"
  
  tags = {
    Environment = "production"
    Service     = "agent-hub"
  }
}

resource "aws_secretsmanager_secret_version" "github_token" {
  secret_id     = aws_secretsmanager_secret.github_token.id
  secret_string = var.github_token
}