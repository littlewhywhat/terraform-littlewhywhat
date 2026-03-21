output "firehose_delivery_stream_name" {
  description = "Name of the Kinesis Firehose delivery stream"
  value       = aws_kinesis_firehose_delivery_stream.extension-events-firehose.name
}

output "firehose_delivery_stream_arn" {
  description = "ARN of the Kinesis Firehose delivery stream"
  value       = aws_kinesis_firehose_delivery_stream.extension-events-firehose.arn
}

output "events_s3_bucket_name" {
  description = "Name of the S3 bucket storing analytics events in Parquet format"
  value       = aws_s3_bucket.extension-events.id
}
