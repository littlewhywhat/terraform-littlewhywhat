resource "aws_iam_user" "terraform_admin" {
  force_destroy = false
  name          = "terraform-admin"
  tags = {
    "device" = "mac-sw-terraform"
  }
  tags_all = {
    "device" = "mac-sw-terraform"
  }
}