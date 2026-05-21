module "apis" {
  source     = "../../modules/apis"
  project_id = var.project_id
}

module "iam" {
  source           = "../../modules/iam"
  project_id       = var.project_id
  project_name     = var.project_name
  vertex_sa_member = module.apis.vertex_sa_member
  depends_on       = [module.apis]
}

module "storage" {
  source       = "../../modules/storage"
  project_id   = var.project_id
  project_name = var.project_name
  region       = var.region
  depends_on   = [module.apis]
}

module "firestore" {
  source       = "../../modules/firestore"
  project_id   = var.project_id
  region       = var.region
  app_sa_email = module.iam.app_sa_email
  depends_on   = [module.apis, module.iam]
}

module "cloud_run" {
  source        = "../../modules/cloud-run"
  project_id    = var.project_id
  project_name  = var.project_name
  region        = var.region
  app_sa_email  = module.iam.app_sa_email
  cicd_sa_email = module.iam.cicd_sa_email
  depends_on    = [module.apis, module.iam]
}

module "model_armor" {
  source       = "../../modules/model-armor"
  project_id   = var.project_id
  project_name = var.project_name
  region       = var.region
  depends_on   = [module.apis]
}

module "agent_engine" {
  source                    = "../../modules/agent-engine"
  project_id                = var.project_id
  project_name              = var.project_name
  region                    = var.region
  app_sa_email              = module.iam.app_sa_email
  logs_bucket_name          = module.storage.logs_bucket_name
  linkedin_mcp_url          = module.cloud_run.linkedin_mcp_url
  model_armor_template_name = module.model_armor.template_name
  depends_on                = [module.apis, module.iam, module.storage, module.cloud_run, module.model_armor]
}

module "cloud_build" {
  source                 = "../../modules/cloud-build"
  project_id             = var.project_id
  project_name           = var.project_name
  region                 = var.region
  project_number         = module.iam.project_number
  cicd_sa_id             = module.iam.cicd_sa_id
  cicd_sa_email          = module.iam.cicd_sa_email
  app_sa_email           = module.iam.app_sa_email
  logs_bucket_name       = module.storage.logs_bucket_name
  tfstate_bucket_name    = module.storage.tfstate_bucket_name
  github_pat_secret_id   = var.github_pat_secret_id
  app_repository_owner   = var.app_repository_owner
  app_repository_name    = var.app_repository_name
  infra_repository_owner = var.infra_repository_owner
  infra_repository_name  = var.infra_repository_name
  depends_on             = [module.apis, module.iam, module.storage]
}

module "telemetry" {
  source               = "../../modules/telemetry"
  project_id           = var.project_id
  project_name         = var.project_name
  region               = var.region
  logs_bucket_name     = module.storage.logs_bucket_name
  feedback_logs_filter = var.feedback_logs_filter
  depends_on           = [module.apis, module.storage]
}
