#!/bin/bash

# Check to see if the environment variable GOOGLE_CLOUD_PROJECT has been set
if [ -z "${GOOGLE_CLOUD_PROJECT}" ]; then
    echo "Environment variable GOOGLE_CLOUD_PROJECT is not set"
    exit 1
fi

echo -e "GOOGLE_CLOUD_PROJECT has been set to \e[33m${GOOGLE_CLOUD_PROJECT}\e[0m"

# Prompt the user that GOOGLE_CLOUD_PROJECT has been set correctly, user will reply with a yes or no. If no, exit script with error message.
read -p "Is the environment variable GOOGLE_CLOUD_PROJECT set correctly? (y/N) " -n 1 -r
echo    # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Environment variable GOOGLE_CLOUD_PROJECT is not set correctly"
    exit 1
fi

# Define the zones to be created in an array with a colon as the delimiter
declare -a zones=(
    "alpha-phac-gc-ca:alpha.phac.gc.ca."
    "alpha-aspc-gc-ca:alpha.aspc.gc.ca."
    "alpha-phac-aspc-gc-ca:alpha.phac-aspc.gc.ca."
    "beta-phac-gc-ca:beta.phac.gc.ca."
    "beta-aspc-gc-ca:beta.aspc.gc.ca."
    "beta-phac-aspc-gc-ca:beta.phac-aspc.gc.ca."
    "data-phac-gc-ca:data.phac.gc.ca."
    "donnes-aspc-gc-ca:donnes.aspc.gc.ca."
    "data-donnes-phac-aspc-gc-ca:data-donnes.phac-aspc.gc.ca."
    "api-phac-gc-ca:api.phac.gc.ca."
    "ipa-aspc-gc-ca:ipa.aspc.gc.ca."
    "api-ipa-phac-aspc-gc-ca:api-ipa.phac-aspc.gc.ca."
    "open-phac-gc-ca:open.phac.gc.ca."
    "ouvert-aspc-gc-ca:ouvert.aspc.gc.ca."
    "open-ouvert-phac-aspc-gc-ca:open-ouvert.phac-aspc.gc.ca."
)

# Loop through the array and create each managed zone
for zone_info in "${zones[@]}"; do
    IFS=: read -r zone_name dns_name <<< "$zone_info"
    gcloud dns --project "${GOOGLE_CLOUD_PROJECT}" managed-zones create "$zone_name" --description="" --dns-name="$dns_name" --visibility="public" --dnssec-state="on" --log-dns-queries
done
