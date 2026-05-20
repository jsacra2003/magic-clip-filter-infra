PROJECT_ID  ?= ge-bootcamp26lis-902
REGION      ?= europe-west1
ENV         ?= dev
TF_BUCKET   := $(PROJECT_ID)-magic-clip-filter-tfstate
TF_PREFIX   := magic-clip-filter/$(ENV)
TF_DIR      := environments/$(ENV)

.PHONY: init plan apply destroy fmt validate

init:
	terraform -chdir=$(TF_DIR) init \
	  -backend-config="bucket=$(TF_BUCKET)" \
	  -backend-config="prefix=$(TF_PREFIX)" \
	  -input=false

validate: init
	terraform -chdir=$(TF_DIR) validate

fmt:
	terraform -chdir=$(TF_DIR) fmt -recursive

plan: init
	terraform -chdir=$(TF_DIR) plan \
	  -input=false \
	  -lock-timeout=300s \
	  -out=/tmp/tfplan

apply: init
	terraform -chdir=$(TF_DIR) plan \
	  -input=false \
	  -lock-timeout=300s \
	  -out=/tmp/tfplan
	terraform -chdir=$(TF_DIR) apply \
	  -auto-approve \
	  -lock-timeout=300s \
	  /tmp/tfplan

destroy: init
	terraform -chdir=$(TF_DIR) destroy \
	  -lock-timeout=300s
