resource "aws_s3_bucket" "extension-events" {
  bucket = "${var.name_prefix}-analytic-events"
}
