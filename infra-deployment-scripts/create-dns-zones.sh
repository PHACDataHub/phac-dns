#!/bin/bash

# Check if the GOOGLE_CLOUD_PROJECT environment variable is set
if [ -z "${GOOGLE_CLOUD_PROJECT}" ]; then
    echo "Environment variable GOOGLE_CLOUD_PROJECT is not set."
    exit 1
else
    echo -e "GOOGLE_CLOUD_PROJECT has been set to \e[33m${GOOGLE_CLOUD_PROJECT}\e[0m"
fi

# Confirm with the user that GOOGLE_CLOUD_PROJECT is set correctly
read -p "Is the environment variable GOOGLE_CLOUD_PROJECT set correctly? (y/N) " -n 1 -r
echo    # Move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Environment variable GOOGLE_CLOUD_PROJECT is not set correctly."
    exit 1
fi

declare -a dnsNames=("alpha.phac.gc.ca" "alpha.aspc.gc.ca" "alpha.phac-aspc.gc.ca" 
                     "beta.phac.gc.ca" "beta.aspc.gc.ca" "beta.phac-aspc.gc.ca" 
                     "data.phac.gc.ca" "donnes.aspc.gc.ca" "data-donnes.phac-aspc.gc.ca" 
                     "api.phac.gc.ca" "ipa.aspc.gc.ca" "api-ipa.phac-aspc.gc.ca" 
                     "open.phac.gc.ca" "ouvert.aspc.gc.ca" "open-ouvert.phac-aspc.gc.ca")

for dnsName in "${dnsNames[@]}"; do
    zoneName="${dnsName//./-}" # Replace dots with dashes for the zone name
    gcloud dns --project "${GOOGLE_CLOUD_PROJECT}" managed-zones create "${zoneName}" \
        --description="" --dns-name="${dnsName}." --visibility="public" \
        --dnssec-state="on" --log-dns-queries
done
