module "bulavka_analytics_pipeline" {
  source      = "./modules/extension-analytics-pipeline"
  region      = var.region
  name_prefix = "extension"
}

moved {
  from = module.extension_analytics_pipeline
  to   = module.bulavka_analytics_pipeline
}

module "sidethreadgpt_analytics_pipeline" {
  source      = "./modules/extension-analytics-pipeline"
  region      = var.region
  name_prefix = "sidethreadgpt"
}

resource "aws_iam_user" "analytics_service_writer" {
  name = "extension-analytics-service-writer"
}

moved {
  from = module.bulavka_analytics_pipeline.aws_iam_user.analytics_service_writer
  to   = aws_iam_user.analytics_service_writer
}

resource "aws_iam_access_key" "analytics_service_writer" {
  user = aws_iam_user.analytics_service_writer.name
}

moved {
  from = module.bulavka_analytics_pipeline.aws_iam_access_key.analytics_service_writer
  to   = aws_iam_access_key.analytics_service_writer
}

resource "aws_iam_user_policy" "analytics_service_writer" {
  name = "extension-analytics-firehose-put"
  user = aws_iam_user.analytics_service_writer.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "firehose:PutRecord",
        "firehose:PutRecordBatch"
      ]
      Resource = [
        module.bulavka_analytics_pipeline.firehose_delivery_stream_arn,
        module.sidethreadgpt_analytics_pipeline.firehose_delivery_stream_arn,
      ]
    }]
  })
}

moved {
  from = module.bulavka_analytics_pipeline.aws_iam_user_policy.analytics_service_writer
  to   = aws_iam_user_policy.analytics_service_writer
}

output "analytics_service_writer_access_key_id" {
  description = "AWS access key ID for the shared analytics service writer"
  value       = aws_iam_access_key.analytics_service_writer.id
}

output "analytics_service_writer_secret_access_key" {
  description = "AWS secret access key for the shared analytics service writer"
  value       = aws_iam_access_key.analytics_service_writer.secret
  sensitive   = true
}

output "bulavka_analytics_firehose_delivery_stream_name" {
  description = "Name of the Kinesis Firehose delivery stream for bulavka analytics events"
  value       = module.bulavka_analytics_pipeline.firehose_delivery_stream_name
}

output "bulavka_analytics_events_s3_bucket_name" {
  description = "Name of the S3 bucket storing bulavka analytics events"
  value       = module.bulavka_analytics_pipeline.events_s3_bucket_name
}

output "sidethreadgpt_analytics_firehose_delivery_stream_name" {
  description = "Name of the Kinesis Firehose delivery stream for sidethreadgpt analytics events"
  value       = module.sidethreadgpt_analytics_pipeline.firehose_delivery_stream_name
}

output "sidethreadgpt_analytics_events_s3_bucket_name" {
  description = "Name of the S3 bucket storing sidethreadgpt analytics events"
  value       = module.sidethreadgpt_analytics_pipeline.events_s3_bucket_name
}
