resource "aws_instance" "agent_hub" {
  ami           = "ami-0c02fb55956c7d316" # Amazon Linux 2
  instance_type = "t2.micro"

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