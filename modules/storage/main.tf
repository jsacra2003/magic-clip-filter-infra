resource "google_storage_bucket" "logs" {
  name                        = "${var.project_id}-${var.project_name}-logs"
  location                    = var.region
  project                     = var.project_id
  uniform_bucket_level_access = true
}

resource "google_storage_bucket" "tfstate" {
  name                        = "${var.project_id}-${var.project_name}-tfstate"
  location                    = var.region
  project                     = var.project_id
  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }
}
