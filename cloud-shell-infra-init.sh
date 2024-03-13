#!/bin/bash

# Check to see if the environment variable GOOGLE_CLOUD_PROJECT has been set 
if [ -z "${GOOGLE_CLOUD_PROJECT}" ]; then
    echo "Environment variable GOOGLE_CLOUD_PROJECT is not set"
    exit 1
fi

echo -e "GOOGLE_CLOUD_PROJECT has been set to \e[33m${GOOGLE_CLOUD_PROJECT}\e[0m"
# Prompt the user that GOOGLE_CLOUD_PROJECT has been set correctly, user will reply with a yes or no. If no Exit script with error message.
read -p "Is the environment variable GOOGLE_CLOUD_PROJECT set correctly? (y/N) " -n 1 -r
echo    # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Environment variable GOOGLE_CLOUD_PROJECT is not set correctly"
    exit 1
fi

# Create a GCP network
gcloud compute networks create "${GOOGLE_CLOUD_PROJECT}-vpc-01" \
    --project="${GOOGLE_CLOUD_PROJECT}" \
    --description="Network for ACM Config Controller for DNS" \
    --subnet-mode=custom \
    --mtu=1460 \
    --bgp-routing-mode=regional

# Create a subnet within the network
gcloud compute networks subnets create "${GOOGLE_CLOUD_PROJECT}-vpc-01-sub-01" \
    --project="${GOOGLE_CLOUD_PROJECT}" \
    --range=10.0.0.0/24 \
    --stack-type=IPV4_ONLY \
    --network="${GOOGLE_CLOUD_PROJECT}-vpc-01" \
    --region=northamerica-northeast1 \
    --enable-private-ip-google-access

# Create an Anthos config controller
gcloud anthos config controller create "${GOOGLE_CLOUD_PROJECT}-dns" \
    --location=northamerica-northeast1 \
    --full-management \
    --network="projects/${GOOGLE_CLOUD_PROJECT}/global/networks/${GOOGLE_CLOUD_PROJECT}-vpc-01" \
    --subnet="projects/${GOOGLE_CLOUD_PROJECT}/regions/northamerica-northeast1/subnetworks/${GOOGLE_CLOUD_PROJECT}-vpc-01-sub-01"

# Configure config controller instance - https://cloud.google.com/anthos-config-management/docs/how-to/config-controller-setup#use-config-controller
gcloud container clusters get-credentials "krmapihost-${GOOGLE_CLOUD_PROJECT}-dns" --region northamerica-northeast1 --project "${GOOGLE_CLOUD_PROJECT}"

SA_EMAIL="$(kubectl get ConfigConnectorContext -n config-control \
    -o jsonpath='{.items[0].spec.googleServiceAccount}' 2> /dev/null)"

# Add IAM policy binding for DNS administration
gcloud projects add-iam-policy-binding "${GOOGLE_CLOUD_PROJECT}" \
    --member "serviceAccount:${SA_EMAIL}" \
    --role "roles/dns.admin" \
    --project "${GOOGLE_CLOUD_PROJECT}"
