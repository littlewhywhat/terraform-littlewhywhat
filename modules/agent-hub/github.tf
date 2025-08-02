
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
          "codedeploy:RegisterApplicationRevision"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_access_key" "github_agent_hub_key" {
  user = aws_iam_user.github_agent_hub.name
}