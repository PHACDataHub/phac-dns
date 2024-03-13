#!/bin/bash

# Define the project ID and SA_EMAIL as variables
PROJECT_ID="$1"

if [ -z "$PROJECT_ID" ]; then
    echo "Usage: $0 <project_id>"
    echo "Example: $0 gcp-my-project "
    exit 1
fi


# Create a GCP network
gcloud compute networks create "${PROJECT_ID}-vpc-01" \
    --project="${PROJECT_ID}" \
    --description="Network for ACM Config Controller for DNS" \
    --subnet-mode=custom \
    --mtu=1460 \
    --bgp-routing-mode=regional

# Create a subnet within the network
gcloud compute networks subnets create "${PROJECT_ID}-vpc-01-sub-01" \
    --project="${PROJECT_ID}" \
    --range=10.0.0.0/24 \
    --stack-type=IPV4_ONLY \
    --network="${PROJECT_ID}-vpc-01" \
    --region=northamerica-northeast1 \
    --enable-private-ip-google-access

# Create an Anthos config controller
gcloud anthos config controller create "${PROJECT_ID}-dns" \
    --location=northamerica-northeast1 \
    --full-management \
    --network="projects/${PROJECT_ID}/global/networks/${PROJECT_ID}-vpc-01" \
    --subnet="projects/${PROJECT_ID}/regions/northamerica-northeast1/subnetworks/${PROJECT_ID}-vpc-01-sub-01"

# Configure config controller instance - https://cloud.google.com/anthos-config-management/docs/how-to/config-controller-setup#use-config-controller
gcloud container clusters get-credentials "krmapihost-${PROJECT_ID}-dns" --region northamerica-northeast1 --project "${PROJECT_ID}"

SA_EMAIL="$(kubectl get ConfigConnectorContext -n config-control \
    -o jsonpath='{.items[0].spec.googleServiceAccount}' 2> /dev/null)"

# Add IAM policy binding
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
    --member "serviceAccount:${SA_EMAIL}" \
    --role "roles/dns.admin" \
    --project "${PROJECT_ID}"
