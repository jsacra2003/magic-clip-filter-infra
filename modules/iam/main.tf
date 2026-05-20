data "google_project" "project" {
  project_id = var.project_id
}

resource "google_service_account" "app_sa" {
  account_id   = "${var.project_name}-app"
  display_name = "${var.project_name} Agent Service Account"
  project      = var.project_id
}

resource "google_service_account" "cicd_sa" {
  account_id   = "${var.project_name}-cicd"
  display_name = "${var.project_name} CI/CD Service Account"
  project      = var.project_id
}

resource "google_project_iam_member" "app_sa_roles" {
  for_each = toset(var.app_sa_roles)
  project  = var.project_id
  role     = each.value
  member   = "serviceAccount:${google_service_account.app_sa.email}"
}

resource "google_project_iam_member" "vertex_ai_sa_roles" {
  for_each = toset(var.app_sa_roles)
  project  = var.project_id
  role     = each.value
  member   = var.vertex_sa_member
}

resource "google_project_iam_member" "cicd_sa_roles" {
  for_each = toset(var.cicd_sa_roles)
  project  = var.project_id
  role     = each.value
  member   = "serviceAccount:${google_service_account.cicd_sa.email}"
}

resource "google_project_iam_member" "default_compute_sa_cloudbuild" {
  project = var.project_id
  role    = "roles/cloudbuild.builds.builder"
  member  = "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"
}
