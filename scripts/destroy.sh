#!/bin/bash

# Name of your RG and Subscription
RG_NAME="cyberlab-rg"
SUB_ID="b5d7ea6a-df7a-4f55-93b2-6245517cd5b3"

echo "🌪️ Starting Terraform destroy..."
terraform destroy -auto-approve

echo "⏳ Waiting for resources to be deleted from resource group: $RG_NAME"

# Poll for RG existence — max 15 attempts (~3 mins)
for i in {1..15}; do
  RG_EXISTS=$(az group exists --name "$RG_NAME")
  if [ "$RG_EXISTS" == "false" ]; then
    echo "✅ Resource group $RG_NAME successfully deleted."
    break
  else
    echo "⏱️ Attempt $i: Still waiting for $RG_NAME to be deleted..."
    sleep 12
  fi
done

# If still exists, force delete the RG contents
if [ "$RG_EXISTS" == "true" ]; then
  echo "⚠️ Resource group still exists. Forcing deletion of remaining resources..."

  RESOURCES=$(az resource list --resource-group "$RG_NAME" --query "[].id" -o tsv)
  for res in $RESOURCES; do
    echo "🧹 Deleting: $res"
    az resource delete --ids "$res"
  done

  echo "🗑️ Deleting the resource group itself..."
  az group delete --name "$RG_NAME" --yes --no-wait
fi

echo "✅ Destroy script completed."
