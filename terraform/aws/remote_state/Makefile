AWS_PROFILE := snowflake-infra
AWS_VAULT   := aws-vault exec $(AWS_PROFILE) --

.PHONY: init plan apply destroy

init: ## terraform init
	$(AWS_VAULT) terraform init

plan: ## terraform plan
	$(AWS_VAULT) terraform plan

apply: ## terraform apply
	$(AWS_VAULT) terraform apply

