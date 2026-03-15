output "vercel_writer_access_key_id" {
  description = "AWS access key ID for the Vercel analytics writer IAM user"
  value       = aws_iam_access_key.vercel_analytics_writer.id
}

output "vercel_writer_secret_access_key" {
  description = "AWS secret access key for the Vercel analytics writer IAM user"
  value       = aws_iam_access_key.vercel_analytics_writer.secret
  sensitive   = true
}

output "firehose_delivery_stream_name" {
  description = "Name of the Kinesis Firehose delivery stream for extension analytics pings"
  value       = aws_kinesis_firehose_delivery_stream.pings.name
}

output "pings_s3_bucket_name" {
  description = "Name of the S3 bucket storing extension analytics ping data in Parquet format"
  value       = aws_s3_bucket.pings.id
}
