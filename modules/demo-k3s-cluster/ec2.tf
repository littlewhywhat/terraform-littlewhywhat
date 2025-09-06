resource "aws_key_pair" "demo_k3s_cluster" {
  key_name   = "demo-k3s-cluster-key"
  public_key = var.demo_k3s_cluster_ssh_public_key
}

resource "aws_instance" "demo_k3s_cluster" {
  ami                    = var.ubuntu_ami_id
  instance_type          = "t3.small"
  key_name              = aws_key_pair.demo_k3s_cluster.key_name
  vpc_security_group_ids = [aws_security_group.demo_k3s_cluster.id]
  iam_instance_profile   = aws_iam_instance_profile.demo_k3s_cluster_profile.name

  tags = {
    Name = "demo-k3s-cluster"
  }

  user_data = file("${path.module}/scripts/k3s-user-data.sh")
}
