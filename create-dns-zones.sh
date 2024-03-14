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

gcloud dns --project "${GOOGLE_CLOUD_PROJECT}" managed-zones create alpha-phac-gc-ca --description="" --dns-name="alpha.phac.gc.ca." --visibility="public" --dnssec-state="on" --log-dns-queries
gcloud dns --project "${GOOGLE_CLOUD_PROJECT}" managed-zones create alpha-aspc-gc-ca --description="" --dns-name="alpha.aspc.gc.ca." --visibility="public" --dnssec-state="on" --log-dns-queries
gcloud dns --project "${GOOGLE_CLOUD_PROJECT}" managed-zones create alpha-phac-aspc-gc-ca --description="" --dns-name="alpha.phac-aspc.gc.ca." --visibility="public" --dnssec-state="on" --log-dns-queries
gcloud dns --project "${GOOGLE_CLOUD_PROJECT}" managed-zones create beta-phac-gc-ca --description="" --dns-name="beta.phac.gc.ca." --visibility="public" --dnssec-state="on" --log-dns-queries
gcloud dns --project "${GOOGLE_CLOUD_PROJECT}" managed-zones create beta-aspc-gc-ca --description="" --dns-name="beta.aspc.gc.ca." --visibility="public" --dnssec-state="on" --log-dns-queries
gcloud dns --project "${GOOGLE_CLOUD_PROJECT}" managed-zones create beta-phac-aspc-gc-ca --description="" --dns-name="beta.phac-aspc.gc.ca." --visibility="public" --dnssec-state="on" --log-dns-queries
gcloud dns --project "${GOOGLE_CLOUD_PROJECT}" managed-zones create data-phac-gc-ca --description="" --dns-name="data.phac.gc.ca." --visibility="public" --dnssec-state="on" --log-dns-queries
gcloud dns --project "${GOOGLE_CLOUD_PROJECT}" managed-zones create donnes-aspc-gc-ca --description="" --dns-name="donnes.aspc.gc.ca." --visibility="public" --dnssec-state="on" --log-dns-queries
gcloud dns --project "${GOOGLE_CLOUD_PROJECT}" managed-zones create data-donnes-phac-aspc-gc-ca --description="" --dns-name="data-donnes.phac-aspc.gc.ca." --visibility="public" --dnssec-state="on" --log-dns-queries
gcloud dns --project "${GOOGLE_CLOUD_PROJECT}" managed-zones create api-phac-gc-ca --description="" --dns-name="api.phac.gc.ca." --visibility="public" --dnssec-state="on" --log-dns-queries
gcloud dns --project "${GOOGLE_CLOUD_PROJECT}" managed-zones create ipa-aspc-gc-ca --description="" --dns-name="ipa.aspc.gc.ca." --visibility="public" --dnssec-state="on" --log-dns-queries
gcloud dns --project "${GOOGLE_CLOUD_PROJECT}" managed-zones create api-ipa-phac-aspc-gc-ca --description="" --dns-name="api-ipa.phac-aspc.gc.ca." --visibility="public" --dnssec-state="on" --log-dns-queries
gcloud dns --project "${GOOGLE_CLOUD_PROJECT}" managed-zones create open-phac-gc-ca --description="" --dns-name="open.phac.gc.ca." --visibility="public" --dnssec-state="on" --log-dns-queries
gcloud dns --project "${GOOGLE_CLOUD_PROJECT}" managed-zones create ouvert-aspc-gc-ca --description="" --dns-name="ouvert.aspc.gc.ca." --visibility="public" --dnssec-state="on" --log-dns-queries
gcloud dns --project "${GOOGLE_CLOUD_PROJECT}" managed-zones create open-ouvert-phac-aspc-gc-ca --description="" --dns-name="open-ouvert.phac-aspc.gc.ca." --visibility="public" --dnssec-state="on" --log-dns-queries
