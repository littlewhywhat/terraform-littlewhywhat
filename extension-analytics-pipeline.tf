module "extension_analytics_pipeline" {
  source = "./modules/extension-analytics-pipeline"
  region = var.region
}

output "extension_analytics_service_writer_access_key_id" {
  description = "AWS access key ID for the analytics service writer"
  value       = module.extension_analytics_pipeline.analytics_service_writer_access_key_id
}

output "extension_analytics_service_writer_secret_access_key" {
  description = "AWS secret access key for the analytics service writer"
  value       = module.extension_analytics_pipeline.analytics_service_writer_secret_access_key
  sensitive   = true
}

output "extension_analytics_firehose_delivery_stream_name" {
  description = "Name of the Kinesis Firehose delivery stream for extension analytics events"
  value       = module.extension_analytics_pipeline.firehose_delivery_stream_name
}

output "extension_analytics_events_s3_bucket_name" {
  description = "Name of the S3 bucket storing extension analytics events"
  value       = module.extension_analytics_pipeline.events_s3_bucket_name
}
