#!/bin/bash

enable_bastion=${1:-false}

echo "🔽 Cloning repo..."
git pull

echo "🔧 Initializing Terraform..."
terraform init

echo "🧠 Planning infrastructure..."
terraform plan -var-file="terraform.tfvars"

echo "⚙️ Applying infrastructure..."
terraform apply -var-file="terraform.tfvars" -var="enable_bastion=true" -auto-approve