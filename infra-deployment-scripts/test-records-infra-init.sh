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

# enable service mesh api
gcloud services enable mesh.googleapis.com --project=${GOOGLE_CLOUD_PROJECT}

# enable fleet mesh feature
gcloud container fleet mesh enable --project=${GOOGLE_CLOUD_PROJECT}

# setup a new cluster
gcloud container clusters create-auto "records-test-phac-dns" \
   --region=northamerica-northeast1 \
   --network="projects/${GOOGLE_CLOUD_PROJECT}/global/networks/${GOOGLE_CLOUD_PROJECT}-vpc-01" \
   --subnetwork="projects/${GOOGLE_CLOUD_PROJECT}/regions/northamerica-northeast1/subnetworks/${GOOGLE_CLOUD_PROJECT}-vpc-01-sub-01" \
   --project=${GOOGLE_CLOUD_PROJECT} \
   --service-account="sa-${GOOGLE_CLOUD_PROJECT}-gke@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com"

# create static ip address
gcloud compute addresses create "records-test-ip" \
  --project="${GOOGLE_CLOUD_PROJECT}" \
  --region=northamerica-northeast1 \

# add ASM and bind cluster to fleet
gcloud container clusters update "records-test-phac-dns" --location=northamerica-northeast1 \
  --fleet-project=${GOOGLE_CLOUD_PROJECT} \
  --project=${GOOGLE_CLOUD_PROJECT}

gcloud container clusters update "records-test-phac-dns" --location=northamerica-northeast1 \
  --project=${GOOGLE_CLOUD_PROJECT} \
  --update-labels=mesh_id=proj-$(gcloud projects describe ${GOOGLE_CLOUD_PROJECT} --format="value(projectNumber)")

gcloud container fleet memberships register ${GKE_CLUSTER_NAME}-membership \
  --gke-cluster=${GKE_LOCATION}/${GKE_CLUSTER_NAME} \
  --enable-workload-identity \
  --project ${PROJECT_ID}

# change fleet management to automatic
gcloud container fleet mesh update \
 --management=automatic \
 --memberships=records-test-phac-dns \
 --project=${GOOGLE_CLOUD_PROJECT} \
 --location=northamerica-northeast1
