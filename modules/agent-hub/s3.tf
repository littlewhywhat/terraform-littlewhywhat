resource "aws_s3_bucket" "agent_hub_artifacts" {
  bucket = "agent-hub-artifacts"
  force_destroy = true
}