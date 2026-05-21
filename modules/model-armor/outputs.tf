output "template_name" {
  description = "Regional Model Armor template name (used by Agent Engine)."
  value       = google_model_armor_template.regional.name
}

output "gemini_enterprise_template_name" {
  description = "EU Model Armor template name (used by Gemini Enterprise)."
  value       = google_model_armor_template.gemini_enterprise.name
}
