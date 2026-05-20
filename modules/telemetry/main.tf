resource "google_bigquery_dataset" "telemetry" {
  project       = var.project_id
  dataset_id    = replace("${var.project_name}_telemetry", "-", "_")
  friendly_name = "${var.project_name} Telemetry"
  location      = var.region
}

resource "google_bigquery_connection" "genai" {
  project       = var.project_id
  location      = var.region
  connection_id = "${var.project_name}-genai-telemetry"
  cloud_resource {}
}

resource "time_sleep" "wait_bq_connection" {
  create_duration = "10s"
  depends_on      = [google_bigquery_connection.genai]
}

resource "google_storage_bucket_iam_member" "bq_connection_logs_reader" {
  bucket = var.logs_bucket_name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_bigquery_connection.genai.cloud_resource[0].service_account_id}"
  depends_on = [time_sleep.wait_bq_connection]
}

resource "time_sleep" "wait_logging_api" {
  create_duration = "30s"
}

resource "google_logging_project_bucket_config" "genai_telemetry" {
  project          = var.project_id
  location         = var.region
  bucket_id        = "${var.project_name}-genai-telemetry"
  retention_days   = 3650
  enable_analytics = true
  depends_on       = [time_sleep.wait_logging_api]
}

resource "google_logging_project_sink" "genai_logs" {
  name        = "${var.project_name}-genai-logs"
  project     = var.project_id
  destination = "logging.googleapis.com/projects/${var.project_id}/locations/${var.region}/buckets/${google_logging_project_bucket_config.genai_telemetry.bucket_id}"
  filter      = "log_name=\"projects/${var.project_id}/logs/gen_ai.client.inference.operation.details\""
  unique_writer_identity = true
  depends_on = [google_logging_project_bucket_config.genai_telemetry]
}

resource "google_logging_project_sink" "feedback_logs" {
  name        = "${var.project_name}-feedback"
  project     = var.project_id
  destination = "logging.googleapis.com/projects/${var.project_id}/locations/${var.region}/buckets/${google_logging_project_bucket_config.genai_telemetry.bucket_id}"
  filter      = var.feedback_logs_filter
  unique_writer_identity = true
  depends_on = [google_logging_project_bucket_config.genai_telemetry]
}

resource "google_logging_linked_dataset" "genai_logs" {
  link_id  = replace("${var.project_name}_genai_telemetry_logs", "-", "_")
  bucket   = google_logging_project_bucket_config.genai_telemetry.bucket_id
  location = var.region
  parent   = "projects/${var.project_id}"
  depends_on = [google_logging_project_sink.genai_logs]
}

resource "time_sleep" "wait_linked_dataset" {
  create_duration = "10s"
  depends_on      = [google_logging_linked_dataset.genai_logs]
}

resource "google_bigquery_table" "completions_external" {
  project             = var.project_id
  dataset_id          = google_bigquery_dataset.telemetry.dataset_id
  table_id            = "completions"
  deletion_protection = false

  external_data_configuration {
    autodetect            = false
    source_format         = "NEWLINE_DELIMITED_JSON"
    source_uris           = ["gs://${var.logs_bucket_name}/completions/*"]
    connection_id         = google_bigquery_connection.genai.name
    ignore_unknown_values = true
    max_bad_records       = 1000
  }

  schema = jsonencode([
    { name = "parts", type = "RECORD", mode = "REPEATED", fields = [
      { name = "type", type = "STRING", mode = "NULLABLE" },
      { name = "content", type = "STRING", mode = "NULLABLE" },
      { name = "mime_type", type = "STRING", mode = "NULLABLE" },
      { name = "uri", type = "STRING", mode = "NULLABLE" },
      { name = "data", type = "BYTES", mode = "NULLABLE" },
      { name = "id", type = "STRING", mode = "NULLABLE" },
      { name = "name", type = "STRING", mode = "NULLABLE" },
      { name = "arguments", type = "JSON", mode = "NULLABLE" },
      { name = "response", type = "JSON", mode = "NULLABLE" },
    ]},
    { name = "role",  type = "STRING",  mode = "NULLABLE" },
    { name = "index", type = "INTEGER", mode = "NULLABLE" },
  ])

  depends_on = [google_bigquery_connection.genai, google_storage_bucket_iam_member.bq_connection_logs_reader]
}
