resource "aws_glue_catalog_database" "analytics" {
  name = "extension_analytics"
}

resource "aws_glue_catalog_table" "pings" {
  database_name = aws_glue_catalog_database.analytics.name
  name          = "pings"
  table_type    = "EXTERNAL_TABLE"

  parameters = {
    "classification"            = "parquet"
    "projection.enabled"        = "true"
    "projection.year.type"      = "integer"
    "projection.year.range"     = "2025,2030"
    "projection.month.type"     = "integer"
    "projection.month.range"    = "1,12"
    "projection.month.digits"   = "2"
    "projection.day.type"       = "integer"
    "projection.day.range"      = "1,31"
    "projection.day.digits"     = "2"
    "storage.location.template" = "s3://${aws_s3_bucket.pings.id}/pings/year=$${year}/month=$${month}/day=$${day}/"
  }

  partition_keys {
    name = "year"
    type = "int"
  }

  partition_keys {
    name = "month"
    type = "int"
  }

  partition_keys {
    name = "day"
    type = "int"
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.pings.id}/pings/"
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    ser_de_info {
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"

      parameters = {
        "serialization.format" = "1"
      }
    }

    columns {
      name = "project_token"
      type = "string"
    }

    columns {
      name = "uuid"
      type = "string"
    }

    columns {
      name = "installed_at"
      type = "bigint"
    }

    columns {
      name = "installed_version"
      type = "string"
    }

    columns {
      name = "updated_at"
      type = "bigint"
    }

    columns {
      name = "updated_version"
      type = "string"
    }

    columns {
      name = "current_version"
      type = "string"
    }

    columns {
      name = "update_url"
      type = "string"
    }

    columns {
      name = "pinged_at"
      type = "bigint"
    }

    columns {
      name = "last_pinged_at"
      type = "bigint"
    }

    columns {
      name = "last_startup_at"
      type = "bigint"
    }

    columns {
      name = "ping_sequence"
      type = "int"
    }

    columns {
      name = "uptime_ms"
      type = "bigint"
    }

    columns {
      name = "is_webdriver"
      type = "boolean"
    }

    columns {
      name = "is_headless"
      type = "boolean"
    }

    columns {
      name = "browser"
      type = "string"
    }

    columns {
      name = "platform"
      type = "string"
    }

    columns {
      name = "language"
      type = "string"
    }
  }
}
