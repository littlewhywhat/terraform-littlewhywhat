output "amazon_linux_ami_id" {
  description = "ID of the latest Amazon Linux 2 AMI"
  value       = data.aws_ami.amazon_linux.id
}

output "backend_web_security_group_id" {
  description = "ID of the backend web security group"
  value       = aws_security_group.backend_web.id
}