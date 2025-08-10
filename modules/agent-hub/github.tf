
resource "aws_iam_user" "github_agent_hub" {
  name = "github-agent-hub"
}

resource "aws_iam_user_policy" "github_agent_hub_policy" {
  name = "github-agent-hub-policy"
  user = aws_iam_user.github_agent_hub.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::agent-hub-artifacts",
          "arn:aws:s3:::agent-hub-artifacts/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "codedeploy:CreateDeployment",
          "codedeploy:GetDeployment",
          "codedeploy:GetDeploymentConfig",
          "codedeploy:RegisterApplicationRevision",
          "codedeploy:GetApplicationRevision"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_access_key" "github_agent_hub_key" {
  user = aws_iam_user.github_agent_hub.name
}

resource "github_repository" "agent_hub" {
  name         = "agent-hub"
  visibility   = "public"
  
  has_issues   = true
  has_wiki     = false
  has_projects = false
  
  allow_merge_commit     = true
  allow_squash_merge     = true
  allow_rebase_merge     = true
  delete_branch_on_merge = true
}

resource "github_actions_secret" "aws_access_key_id" {
  repository      = github_repository.agent_hub.name
  secret_name     = "AWS_ACCESS_KEY_ID"
  plaintext_value = aws_iam_access_key.github_agent_hub_key.id
}

resource "github_actions_secret" "aws_secret_access_key" {
  repository      = github_repository.agent_hub.name
  secret_name     = "AWS_SECRET_ACCESS_KEY"
  plaintext_value = aws_iam_access_key.github_agent_hub_key.secret
}

resource "github_repository_webhook" "agent_hub_ping" {
  repository = github_repository.agent_hub.name

  configuration {
    url          = "http://${aws_instance.agent_hub.public_ip}:8000/ping"
    content_type = "json"
    insecure_ssl = false
  }

  active = true

  events = ["issue_comment"]
}


