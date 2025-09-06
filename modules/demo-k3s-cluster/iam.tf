resource "aws_iam_role" "demo_k3s_cluster_role" {
  name = "demo-k3s-cluster-role"

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

resource "aws_iam_role_policy" "demo_k3s_cluster_policy" {
  name = "demo-k3s-cluster-policy"
  role = aws_iam_role.demo_k3s_cluster_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceTypes"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "demo_k3s_cluster_profile" {
  name = "demo-k3s-cluster-profile"
  role = aws_iam_role.demo_k3s_cluster_role.name
}
