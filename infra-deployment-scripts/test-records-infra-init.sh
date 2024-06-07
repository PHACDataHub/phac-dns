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

gcloud container clusters create-auto "records-test-phac-dns" \
   --region=northamerica-northeast1 \
   --network="projects/${GOOGLE_CLOUD_PROJECT}/global/networks/${GOOGLE_CLOUD_PROJECT}-vpc-01" \
   --subnetwork="projects/${GOOGLE_CLOUD_PROJECT}/regions/northamerica-northeast1/subnetworks/${GOOGLE_CLOUD_PROJECT}-vpc-01-sub-01" \
   --project=${GOOGLE_CLOUD_PROJECT} \
   --service-account="sa-${GOOGLE_CLOUD_PROJECT}-gke@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com"

gcloud compute addresses create "records-test-ip" \
  --project="${GOOGLE_CLOUD_PROJECT}" \
  --region=northamerica-northeast1 \
