data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

resource "aws_iam_role" "ec2_codedeploy_role" {
  name = "ec2-codedeploy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "ec2_codedeploy_policy" {
  name = "ec2-codedeploy-policy"
  role = aws_iam_role.ec2_codedeploy_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::aws-codedeploy-*/*",
          "arn:aws:s3:::aws-codedeploy-*",
          "arn:aws:s3:::agent-hub-artifacts",
          "arn:aws:s3:::agent-hub-artifacts/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "ec2:DescribeInstanceStatus",
          "tag:GetResources",
          "autoscaling:CompleteLifecycleAction",
          "autoscaling:DeleteLifecycleHook",
          "autoscaling:DescribeLifecycleHooks",
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:PutLifecycleHook",
          "autoscaling:RecordLifecycleActionHeartbeat"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue"
        ],
        Resource = [
          "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:agent-hub/*"
        ]
      }
    ]
  })
}

# Create instance profile
resource "aws_iam_instance_profile" "ec2_codedeploy_profile" {
  name = "ec2-codedeploy-profile"
  role = aws_iam_role.ec2_codedeploy_role.name
}

resource "aws_key_pair" "agent_hub" {
  key_name   = "agent-hub-key"
  public_key = var.agent_hub_ssh_public_key
}

resource "aws_instance" "agent_hub" {
  ami                    = var.amazon_linux_ami_id
  instance_type          = "t2.micro"
  key_name              = aws_key_pair.agent_hub.key_name
  vpc_security_group_ids = [var.ec2_service_security_group_id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_codedeploy_profile.name

  tags = {
    Name = "agent-hub"
  }

  user_data = file("${path.module}/scripts/user-data.sh")

  lifecycle {
    ignore_changes = [ami]
  }
}