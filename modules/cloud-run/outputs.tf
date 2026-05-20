output "linkedin_mcp_url"   { value = google_cloud_run_v2_service.linkedin_mcp.uri }
output "docker_repo_name"  { value = google_artifact_registry_repository.docker.name }
output "docker_repo_location" { value = google_artifact_registry_repository.docker.location }
