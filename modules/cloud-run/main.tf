# Artifact Registry
resource "google_artifact_registry_repository" "docker" {
  project       = var.project_id
  location      = var.region
  repository_id = var.project_name
  format        = "DOCKER"
}

resource "google_artifact_registry_repository_iam_member" "cicd_writer" {
  project    = var.project_id
  location   = var.region
  repository = google_artifact_registry_repository.docker.name
  role       = "roles/artifactregistry.writer"
  member     = "serviceAccount:${var.cicd_sa_email}"
}

resource "google_artifact_registry_repository_iam_member" "app_reader" {
  project    = var.project_id
  location   = var.region
  repository = google_artifact_registry_repository.docker.name
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${var.app_sa_email}"
}

# LinkedIn access token secret
resource "google_secret_manager_secret" "linkedin_token" {
  project   = var.project_id
  secret_id = "linkedin-access-token"
  replication { auto {} }
}

resource "google_secret_manager_secret_version" "linkedin_token_placeholder" {
  secret      = google_secret_manager_secret.linkedin_token.id
  secret_data = "REPLACE_ME"
  lifecycle { ignore_changes = [secret_data] }
}

resource "google_secret_manager_secret_iam_member" "app_sa_token" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.linkedin_token.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${var.app_sa_email}"
}

# LinkedIn MCP Cloud Run service
resource "google_cloud_run_v2_service" "linkedin_mcp" {
  name     = "${var.project_name}-linkedin-mcp"
  location = var.region
  project  = var.project_id

  template {
    service_account = var.app_sa_email

    containers {
      image = "gcr.io/cloudrun/placeholder"

      env {
        name  = "MCP_TRANSPORT"
        value = "sse"
      }

      env {
        name = "LINKEDIN_ACCESS_TOKEN"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.linkedin_token.secret_id
            version = "latest"
          }
        }
      }

      ports { container_port = 8080 }

      resources {
        limits = { cpu = "1", memory = "512Mi" }
      }
    }
  }

  lifecycle {
    ignore_changes = [template[0].containers[0].image]
  }

  depends_on = [
    google_secret_manager_secret_version.linkedin_token_placeholder,
    google_artifact_registry_repository.docker,
  ]
}

resource "google_cloud_run_v2_service_iam_member" "public_invoker" {
  project  = var.project_id
  location = var.region
  name     = google_cloud_run_v2_service.linkedin_mcp.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
