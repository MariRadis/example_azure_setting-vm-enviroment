#!/bin/bash

# Log in to Azure (interactive)
az login

# todo
# Set the subscription (optional, if multiple subscriptions)
# az account set --subscription "<your-subscription-id>"

# Initialize and plan with Terraform
#terraform init
terraform plan
