
flux == flux conf
infrastructure includes all zones, and config-connector CRDs


curl -s https://fluxcd.io/install.sh | sudo FLUX_VERSION=2.3.0 bash


flux bootstrap git --url=ssh://git@github.com/PHACDataHub/phac-dns --path=k8s/clusters/gke --branch=new-autopilot-cluster-no-anthos --components="source-controller,kustomize-controller"

