data "aws_caller_identity" "current" {}

resource "aws_iam_role" "firehose" {
  name = "extension-events-firehose"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "firehose.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "firehose" {
  name = "extension-events-firehose"
  role = aws_iam_role.firehose.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:AbortMultipartUpload",
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
          "s3:PutObject"
        ]
        Resource = [
          aws_s3_bucket.extension-events.arn,
          "${aws_s3_bucket.extension-events.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "glue:GetTable",
          "glue:GetTableVersion",
          "glue:GetTableVersions"
        ]
        Resource = [
          "arn:aws:glue:${var.region}:${data.aws_caller_identity.current.account_id}:catalog",
          "arn:aws:glue:${var.region}:${data.aws_caller_identity.current.account_id}:database/${aws_glue_catalog_database.analytics.name}",
          "arn:aws:glue:${var.region}:${data.aws_caller_identity.current.account_id}:table/${aws_glue_catalog_database.analytics.name}/${aws_glue_catalog_table.extension-events.name}"
        ]
      }
    ]
  })
}

resource "aws_iam_user" "analytics_service_writer" {
  name = "extension-analytics-service-writer"
}

resource "aws_iam_access_key" "analytics_service_writer" {
  user = aws_iam_user.analytics_service_writer.name
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
      Resource = aws_kinesis_firehose_delivery_stream.extension-events-firehose.arn
    }]
  })
}
