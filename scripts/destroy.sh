#!/bin/bash

echo "⚠️ This will destroy all lab infrastructure. Continue?"
read -p "Type 'yes' to proceed: " confirm

if [[ "$confirm" == "yes" ]]; then
    terraform destroy -var-file="terraform.tfvars" -auto-approve
    echo "🗑️ Infrastructure destroyed"
else
    echo "❌ Aborted"
fi

