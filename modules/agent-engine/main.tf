data "google_storage_bucket_object_content" "dummy_source_b64" {
  name   = "dummy/source-b64.txt"
  bucket = "agent-starter-pack"
}

resource "google_vertex_ai_reasoning_engine" "app" {
  display_name = var.project_name
  description  = "Magic Clip Filter — Trends → YouTube → PG-16 pipeline"
  region       = var.region
  project      = var.project_id

  spec {
    agent_framework = "google-adk"
    service_account = var.app_sa_email

    deployment_spec {
      min_instances         = 1
      max_instances         = 10
      container_concurrency = 9

      resource_limits = { cpu = "4", memory = "8Gi" }

      env { name = "LOGS_BUCKET_NAME",                                value = var.logs_bucket_name }
      env { name = "LINKEDIN_MCP_URL",                                value = var.linkedin_mcp_url }
      env { name = "OTEL_INSTRUMENTATION_GENAI_CAPTURE_MESSAGE_CONTENT", value = "true" }
      env { name = "GOOGLE_CLOUD_AGENT_ENGINE_ENABLE_TELEMETRY",       value = "true" }
    }

    source_code_spec {
      inline_source {
        source_archive = trimspace(data.google_storage_bucket_object_content.dummy_source_b64.content)
      }
      python_spec {
        entrypoint_module = "google_trends_agent.agent_engine_app"
        entrypoint_object = "agent_engine"
        requirements_file = "google_trends_agent/app_utils/.requirements.txt"
        version           = "3.12"
      }
    }
  }

  lifecycle {
    ignore_changes = [spec[0].source_code_spec]
  }
}
