# magic-clip-filter-infra

Infrastructure-as-Code for the [magic-clip-filter](https://github.com/jsacra2003/magic-clip-filter) project.

## Structure

```
environments/dev/   ← environment entry point (calls all modules)
modules/
  apis/             ← GCP API enablement
  iam/              ← service accounts + IAM roles
  storage/          ← GCS buckets (logs, tfstate)
  firestore/        ← Firestore database (post dedup)
  cloud-run/        ← LinkedIn MCP server + Artifact Registry + Secret Manager
  agent-engine/     ← Vertex AI Agent Engine
  cloud-build/      ← GitHub connection + triggers for both repos
  telemetry/        ← BigQuery telemetry + log sinks
pipelines/
  terraform-plan.yaml   ← PR trigger: init + validate + plan → store in GCS
  terraform-apply.yaml  ← main push trigger: init + plan + apply
```

## Bootstrap (one-time)

```bash
# 1. Create the tfstate bucket
gsutil mb -l europe-west1 gs://ge-bootcamp26lis-902-magic-clip-filter-tfstate

# 2. Store GitHub PAT in Secret Manager
gcloud secrets create github-pat --project ge-bootcamp26lis-902
echo -n "ghp_YOUR_TOKEN" | gcloud secrets versions add github-pat --data-file=-

# 3. Apply
cd environments/dev
terraform init \
  -backend-config="bucket=ge-bootcamp26lis-902-magic-clip-filter-tfstate" \
  -backend-config="prefix=magic-clip-filter/dev"
terraform apply -var-file=terraform.tfvars
```

After the first apply, Cloud Build triggers watch both repos automatically.

## CI/CD

| Trigger | Event | Pipeline |
|---|---|---|
| `infra-terraform-plan` | PR to this repo | `pipelines/terraform-plan.yaml` — plan only, stores artifact in GCS |
| `infra-terraform-apply` | Push to `main` | `pipelines/terraform-apply.yaml` — plan + apply |
| `app-pr-checks` | PR to app repo | `.cloudbuild/pr_checks.yaml` in app repo |
| `app-deploy` | Push to app `main` | `.cloudbuild/deploy.yaml` in app repo |
