output "amazon_linux_ami_id" {
  description = "ID of the latest Amazon Linux 2 AMI"
  value       = data.aws_ami.amazon_linux.id
}

output "ubuntu_ami_id" {
  description = "ID of the latest Ubuntu 22.04 LTS AMI"
  value       = data.aws_ami.ubuntu.id
}

output "ec2_service_security_group_id" {
  description = "ID of the EC2 service security group"
  value       = aws_security_group.ec2_service.id
}