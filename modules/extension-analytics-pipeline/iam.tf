data "aws_caller_identity" "current" {}

resource "aws_iam_role" "firehose" {
  name = "extension-analytics-firehose"

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
  name = "extension-analytics-firehose"
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
          aws_s3_bucket.pings.arn,
          "${aws_s3_bucket.pings.arn}/*"
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
          "arn:aws:glue:${var.region}:${data.aws_caller_identity.current.account_id}:table/${aws_glue_catalog_database.analytics.name}/${aws_glue_catalog_table.pings.name}"
        ]
      }
    ]
  })
}

resource "aws_iam_user" "vercel_analytics_writer" {
  name = "extension-analytics-vercel-writer"
}

resource "aws_iam_access_key" "vercel_analytics_writer" {
  user = aws_iam_user.vercel_analytics_writer.name
}

resource "aws_iam_user_policy" "vercel_analytics_writer" {
  name = "extension-analytics-firehose-put"
  user = aws_iam_user.vercel_analytics_writer.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "firehose:PutRecord",
        "firehose:PutRecordBatch"
      ]
      Resource = aws_kinesis_firehose_delivery_stream.pings.arn
    }]
  })
}
