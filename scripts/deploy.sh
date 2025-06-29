#!/bin/bash

echo "🔽 Cloning repo..."
git pull

echo "🔧 Initializing Terraform..."
terraform init

echo "🧠 Planning infrastructure..."
terraform plan -var-file="terraform.tfvars"

echo "⚙️ Applying infrastructure..."
terraform apply -var-file="terraform.tfvars" -auto-approve