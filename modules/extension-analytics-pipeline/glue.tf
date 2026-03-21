resource "aws_glue_catalog_database" "analytics" {
  name = "${var.name_prefix}_analytics"
}

resource "aws_glue_catalog_table" "extension-events" {
  database_name = aws_glue_catalog_database.analytics.name
  name          = "${var.name_prefix}-events"
  table_type    = "EXTERNAL_TABLE"

  parameters = {
    "classification"            = "parquet"
    "projection.enabled"        = "true"
    "projection.year.type"      = "injected"
    "projection.month.type"     = "injected"
    "projection.day.type"       = "injected"
    "storage.location.template" = "s3://${aws_s3_bucket.extension-events.id}/events/year=$${year}/month=$${month}/day=$${day}/"
  }

  partition_keys {
    name = "year"
    type = "string"
  }

  partition_keys {
    name = "month"
    type = "string"
  }

  partition_keys {
    name = "day"
    type = "string"
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.extension-events.id}/events/"
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    ser_de_info {
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"

      parameters = {
        "serialization.format" = "1"
      }
    }

    columns {
      name = "uuid"
      type = "string"
    }

    columns {
      name = "current_version"
      type = "string"
    }

    columns {
      name = "timestamp"
      type = "bigint"
    }

    columns {
      name = "event_type"
      type = "string"
    }

    columns {
      name = "received_at"
      type = "bigint"
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

    columns {
      name = "bot_risk_webdriver"
      type = "boolean"
    }

    columns {
      name = "bot_risk_headless"
      type = "boolean"
    }

    columns {
      name = "bot_risk_install_to_ping_fast"
      type = "boolean"
    }

    columns {
      name = "bot_risk_uptime_suspicious"
      type = "boolean"
    }

    columns {
      name = "action"
      type = "string"
    }

    columns {
      name = "action_data"
      type = "string"
    }

    columns {
      name = "env"
      type = "string"
    }
  }
}
