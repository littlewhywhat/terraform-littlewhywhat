resource "aws_key_pair" "agent_hub" {
  key_name   = "agent-hub-key"
  public_key = var.agent_hub_ssh_public_key
}

resource "aws_instance" "agent_hub" {
  ami                    = var.amazon_linux_ami_id
  instance_type          = "t2.micro"
  key_name              = aws_key_pair.agent_hub.key_name
  vpc_security_group_ids = [var.ec2_service_security_group_id]

  tags = {
    Name = "agent-hub"
  }

  user_data = file("${path.module}/scripts/user-data.sh")
}