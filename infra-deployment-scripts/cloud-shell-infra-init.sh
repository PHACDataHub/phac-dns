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

# 1. create a dns-admin-sa
# 2. attach dns-admin-sa to project with dns.Admin role
# 3. create new cluster-sa

gcloud iam service-accounts create "sa-${GOOGLE_CLOUD_PROJECT}-gke" \
    --display-name="sa-${GOOGLE_CLOUD_PROJECT}-gke" \
    --project=${GOOGLE_CLOUD_PROJECT}

gcloud projects add-iam-policy-binding ${GOOGLE_CLOUD_PROJECT} \
    --member "serviceAccount:sa-${GOOGLE_CLOUD_PROJECT}-gke@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com" \
    --role roles/logging.logWriter

gcloud projects add-iam-policy-binding ${GOOGLE_CLOUD_PROJECT} \
    --member "serviceAccount:sa-${GOOGLE_CLOUD_PROJECT}-gke@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com" \
    --role roles/monitoring.metricWriter

gcloud projects add-iam-policy-binding ${GOOGLE_CLOUD_PROJECT} \
    --member "serviceAccount:sa-${GOOGLE_CLOUD_PROJECT}-gke@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com" \
    --role roles/monitoring.viewer

gcloud projects add-iam-policy-binding ${GOOGLE_CLOUD_PROJECT} \
    --member "serviceAccount:sa-${GOOGLE_CLOUD_PROJECT}-gke@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com" \
    --role roles/stackdriver.resourceMetadata.writer

gcloud projects add-iam-policy-binding ${GOOGLE_CLOUD_PROJECT} \
    --member "serviceAccount:sa-${GOOGLE_CLOUD_PROJECT}-gke@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com" \
    --role roles/autoscaling.metricsWriter

# Create SA for DNS Admin
gcloud iam service-accounts create "sa-${GOOGLE_CLOUD_PROJECT}-phac-dns" \
    --display-name="sa-${GOOGLE_CLOUD_PROJECT}-phac-dns" \
    --project=${GOOGLE_CLOUD_PROJECT}

# Add IAM policy binding for DNS administration
gcloud projects add-iam-policy-binding "${GOOGLE_CLOUD_PROJECT}" \
    --member "serviceAccount:sa-${GOOGLE_CLOUD_PROJECT}-phac-dns@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com" \
    --role "roles/dns.admin" \
    --project "${GOOGLE_CLOUD_PROJECT}"
    
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
gcloud container clusters create-auto "${GOOGLE_CLOUD_PROJECT}-phac-dns" \
   --region=northamerica-northeast1 \
   --network="projects/${GOOGLE_CLOUD_PROJECT}/global/networks/${GOOGLE_CLOUD_PROJECT}-vpc-01" \
   --subnetwork="projects/${GOOGLE_CLOUD_PROJECT}/regions/northamerica-northeast1/subnetworks/${GOOGLE_CLOUD_PROJECT}-vpc-01-sub-01" \
   --project=${GOOGLE_CLOUD_PROJECT} \
   --service-account="sa-${GOOGLE_CLOUD_PROJECT}-gke@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com"

# Configure config controller instance - https://cloud.google.com/anthos-config-management/docs/how-to/config-controller-setup#use-config-controller
gcloud container clusters get-credentials "${GOOGLE_CLOUD_PROJECT}-phac-dns" --region northamerica-northeast1 --project "${GOOGLE_CLOUD_PROJECT}"

SA_EMAIL="$(kubectl get ConfigConnectorContext -n config-control \
    -o jsonpath='{.items[0].spec.googleServiceAccount}' 2> /dev/null)"


