output "app_sa_email" {
  value = google_service_account.app_sa.email
}

output "app_sa_id" {
  value = google_service_account.app_sa.id
}

output "cicd_sa_email" {
  value = google_service_account.cicd_sa.email
}

output "cicd_sa_id" {
  value = google_service_account.cicd_sa.id
}

output "project_number" {
  value = data.google_project.project.number
}
