variable "project_id" {
  type        = string
  description = "GCP project ID."
}

variable "project_name" {
  type        = string
  description = "Resource name prefix."
  default     = "magic-clip-filter"
}

variable "region" {
  type        = string
  description = "GCP region."
  default     = "europe-west1"
}

variable "github_pat_secret_id" {
  type        = string
  description = "Secret Manager ID for the GitHub PAT."
  default     = "github-pat"
}

variable "app_repository_owner" {
  type        = string
  description = "GitHub owner of the application repo."
}

variable "app_repository_name" {
  type        = string
  description = "GitHub name of the application repo."
  default     = "magic-clip-filter"
}

variable "infra_repository_owner" {
  type        = string
  description = "GitHub owner of the infra repo."
}

variable "infra_repository_name" {
  type        = string
  description = "GitHub name of the infra repo."
  default     = "magic-clip-filter-infra"
}

variable "feedback_logs_filter" {
  type    = string
  default = "jsonPayload.log_type=\"feedback\" jsonPayload.service_name=\"magic-clip-filter\""
}
