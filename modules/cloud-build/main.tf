# GitHub PAT (must exist in Secret Manager before first terraform apply)
data "google_secret_manager_secret" "github_pat" {
  project   = var.project_id
  secret_id = var.github_pat_secret_id
}

resource "google_secret_manager_secret_iam_member" "cloudbuild_pat_accessor" {
  project   = var.project_id
  secret_id = data.google_secret_manager_secret.github_pat.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:service-${var.project_number}@gcp-sa-cloudbuild.iam.gserviceaccount.com"
}

# GitHub connection
resource "google_cloudbuildv2_connection" "github" {
  project  = var.project_id
  location = var.region
  name     = "${var.project_name}-github"

  github_config {
    authorizer_credential {
      oauth_token_secret_version = "${data.google_secret_manager_secret.github_pat.id}/versions/latest"
    }
  }

  depends_on = [google_secret_manager_secret_iam_member.cloudbuild_pat_accessor]
}

# App repo link
resource "google_cloudbuildv2_repository" "app_repo" {
  project           = var.project_id
  location          = var.region
  name              = var.app_repository_name
  parent_connection = google_cloudbuildv2_connection.github.id
  remote_uri        = "https://github.com/${var.app_repository_owner}/${var.app_repository_name}.git"
}

# Infra repo link
resource "google_cloudbuildv2_repository" "infra_repo" {
  project           = var.project_id
  location          = var.region
  name              = var.infra_repository_name
  parent_connection = google_cloudbuildv2_connection.github.id
  remote_uri        = "https://github.com/${var.infra_repository_owner}/${var.infra_repository_name}.git"
}

# ── App repo triggers ────────────────────────────────────────────────────────

resource "google_cloudbuild_trigger" "app_pr_checks" {
  name            = "app-pr-checks"
  project         = var.project_id
  location        = var.region
  description     = "Run tests on app repo pull requests"
  service_account = var.cicd_sa_id

  repository_event_config {
    repository = google_cloudbuildv2_repository.app_repo.id
    pull_request { branch = "^main$" }
  }

  filename = ".cloudbuild/pr_checks.yaml"
  included_files = [
    "google_trends_agent/**", "agent04_media_check_agent/**",
    "agent05_youtube_highlights_agent/**", "magic_clip_pipeline/**",
    "linkedin_mcp_server/**", "tests/**", "pyproject.toml", "uv.lock",
  ]
  include_build_logs = "INCLUDE_BUILD_LOGS_WITH_STATUS"
}

resource "google_cloudbuild_trigger" "app_deploy" {
  name            = "app-deploy"
  project         = var.project_id
  location        = var.region
  description     = "Deploy app to Agent Engine on push to main"
  service_account = var.cicd_sa_id

  repository_event_config {
    repository = google_cloudbuildv2_repository.app_repo.id
    push { branch = "^main$" }
  }

  filename = ".cloudbuild/deploy.yaml"
  included_files = [
    "google_trends_agent/**", "agent04_media_check_agent/**",
    "agent05_youtube_highlights_agent/**", "magic_clip_pipeline/**",
    "linkedin_mcp_server/**", "pyproject.toml", "uv.lock",
  ]
  substitutions = {
    _PROJECT_ID          = var.project_id
    _REGION              = var.region
    _LOGS_BUCKET_NAME    = var.logs_bucket_name
    _APP_SERVICE_ACCOUNT = var.app_sa_email
  }
  include_build_logs = "INCLUDE_BUILD_LOGS_WITH_STATUS"
}

# ── Infra repo triggers ──────────────────────────────────────────────────────

resource "google_cloudbuild_trigger" "infra_plan" {
  name            = "infra-terraform-plan"
  project         = var.project_id
  location        = var.region
  description     = "Run terraform plan on infra repo pull requests"
  service_account = var.cicd_sa_id

  repository_event_config {
    repository = google_cloudbuildv2_repository.infra_repo.id
    pull_request { branch = "^main$" }
  }

  filename = "pipelines/terraform-plan.yaml"
  substitutions = {
    _ENV              = "dev"
    _TF_STATE_BUCKET  = var.tfstate_bucket_name
    _TF_STATE_PREFIX  = "${var.project_name}/dev"
  }
  include_build_logs = "INCLUDE_BUILD_LOGS_WITH_STATUS"
}

resource "google_cloudbuild_trigger" "infra_apply" {
  name            = "infra-terraform-apply"
  project         = var.project_id
  location        = var.region
  description     = "Run terraform apply on push to infra main"
  service_account = var.cicd_sa_id

  repository_event_config {
    repository = google_cloudbuildv2_repository.infra_repo.id
    push { branch = "^main$" }
  }

  filename = "pipelines/terraform-apply.yaml"
  substitutions = {
    _ENV              = "dev"
    _TF_STATE_BUCKET  = var.tfstate_bucket_name
    _TF_STATE_PREFIX  = "${var.project_name}/dev"
  }
  include_build_logs = "INCLUDE_BUILD_LOGS_WITH_STATUS"
}
