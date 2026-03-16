output "analytics_service_writer_access_key_id" {
  description = "AWS access key ID for the analytics service writer IAM user"
  value       = aws_iam_access_key.analytics_service_writer.id
}

output "analytics_service_writer_secret_access_key" {
  description = "AWS secret access key for the analytics service writer IAM user"
  value       = aws_iam_access_key.analytics_service_writer.secret
  sensitive   = true
}

output "firehose_delivery_stream_name" {
  description = "Name of the Kinesis Firehose delivery stream for extension analytics events"
  value       = aws_kinesis_firehose_delivery_stream.extension-events-firehose.name
}

output "events_s3_bucket_name" {
  description = "Name of the S3 bucket storing extension analytics events in Parquet format"
  value       = aws_s3_bucket.extension-events.id
}
