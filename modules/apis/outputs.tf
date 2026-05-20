output "vertex_sa_member" {
  description = "Vertex AI service identity member string."
  value       = google_project_service_identity.vertex_sa.member
}

output "services_done" {
  description = "Dependency token — use depends_on = [module.apis] in callers."
  value       = google_project_service.services[*].service
}
