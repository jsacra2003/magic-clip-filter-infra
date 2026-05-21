variable "project_id" {
  type        = string
  description = "GCP project ID."
}

variable "project_name" {
  type        = string
  description = "Project name used as base for resource naming."
}

variable "vertex_sa_member" {
  type        = string
  description = "Vertex AI service identity member (from apis module output)."
}

variable "app_sa_roles" {
  type        = list(string)
  description = "IAM roles for the agent runtime service account."
  default = [
    "roles/aiplatform.user",
    "roles/bigquery.user",
    "roles/cloudtrace.agent",
    "roles/datastore.user",
    "roles/logging.logWriter",
    "roles/modelarmor.user",
    "roles/secretmanager.secretAccessor",
    "roles/serviceusage.serviceUsageConsumer",
    "roles/storage.admin",
  ]
}

variable "cicd_sa_roles" {
  type        = list(string)
  description = "IAM roles for the CI/CD service account."
  default = [
    "roles/aiplatform.user",
    "roles/cloudbuild.builds.builder",
    "roles/cloudtrace.agent",
    "roles/iam.serviceAccountUser",
    "roles/logging.logWriter",
    "roles/run.developer",
    "roles/serviceusage.serviceUsageConsumer",
    "roles/storage.admin",
  ]
}
