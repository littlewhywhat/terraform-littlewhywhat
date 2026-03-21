resource "aws_kinesis_firehose_delivery_stream" "extension-events-firehose" {
  name        = "${var.name_prefix}-events-firehose"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn            = aws_iam_role.firehose.arn
    bucket_arn          = aws_s3_bucket.extension-events.arn
    prefix              = "events/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/"
    error_output_prefix = "errors/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/!{firehose:error-output-type}/"
    buffering_size      = 128
    buffering_interval  = 300

    data_format_conversion_configuration {
      input_format_configuration {
        deserializer {
          open_x_json_ser_de {}
        }
      }

      output_format_configuration {
        serializer {
          parquet_ser_de {}
        }
      }

      schema_configuration {
        database_name = aws_glue_catalog_database.analytics.name
        table_name    = aws_glue_catalog_table.extension-events.name
        role_arn      = aws_iam_role.firehose.arn
        region        = var.region
      }
    }
  }
}
