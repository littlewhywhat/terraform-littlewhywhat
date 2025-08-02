module "backend_deployment" {
  source = "../backend-deployment"
}

resource "aws_key_pair" "agent_hub" {
  key_name   = "agent-hub-key"
  public_key = var.agent_hub_ssh_public_key
}

resource "aws_instance" "agent_hub" {
  ami                    = module.backend_deployment.amazon_linux_ami_id
  instance_type          = "t2.micro"
  key_name              = aws_key_pair.agent_hub.key_name
  vpc_security_group_ids = [module.backend_deployment.backend_web_security_group_id]

  tags = {
    Name = "agent-hub"
  }

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y ruby wget python3 git
              cd /home/ec2-user
              wget https://aws-codedeploy-us-east-1.s3.us-east-1.amazonaws.com/latest/install
              chmod +x ./install
              ./install auto
              systemctl start codedeploy-agent
              systemctl enable codedeploy-agent
              EOF
}