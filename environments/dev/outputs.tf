output "app_sa_email"               { value = module.iam.app_sa_email }
output "logs_bucket_name"           { value = module.storage.logs_bucket_name }
output "tfstate_bucket_name"        { value = module.storage.tfstate_bucket_name }
output "agent_engine_name"          { value = module.agent_engine.resource_name }
output "linkedin_mcp_url"           { value = module.cloud_run.linkedin_mcp_url }
output "telemetry_dataset_id"       { value = module.telemetry.dataset_id }
output "model_armor_template_name"  { value = module.model_armor.template_name }
