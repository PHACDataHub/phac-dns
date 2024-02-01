gcloud compute networks create php-01hhmj81fhp-vpc-01 \
    --project=php-01hhmj81fhp \
    --description=Network\ for\ ACM\ Config\ Controller\ for\ DNS \
    --subnet-mode=custom \
    --mtu=1460 \
    --bgp-routing-mode=regional 

gcloud compute networks subnets create php-01hhmj81fhp-vpc-01-sub-01 \
    --project=php-01hhmj81fhp \
    --range=10.0.0.0/24 \
    --stack-type=IPV4_ONLY \
    --network=php-01hhmj81fhp-vpc-01 \
    --region=northamerica-northeast1 \
    --enable-private-ip-google-access

gcloud anthos config controller create php-01hhmj81fhp-dns \
    --location=northamerica-northeast1 \
    --full-management \
    --network=projects/php-01hhmj81fhp/global/networks/php-01hhmj81fhp-vpc-01 \
    --subnet=projects/php-01hhmj81fhp/regions/northamerica-northeast1/subnetworks/php-01hhmj81fhp-vpc-01-sub-01 
