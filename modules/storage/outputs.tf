output "logs_bucket_name"   { value = google_storage_bucket.logs.name }
output "tfstate_bucket_name" { value = google_storage_bucket.tfstate.name }
