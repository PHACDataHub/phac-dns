# Directory structure

- `components` dir contains controller CRDs (`./components/controllers`), their configurations (`./components/configs`) and KCC definitions for the DNS zones (`./components/infrastructure`)
- `clusters` dir contains the Flux configuration per cluster

```sh
k8s
├── clusters
│   └── gke
│       ├── dns-records.yaml
│       ├── flux-system
│       │   ├── gotk-components.yaml
│       │   ├── gotk-sync.yaml
│       │   └── kustomization.yaml
│       └── infrastructure.yaml
├── components
│   ├── configs
│   │   └── configconnector.yaml
│   ├── controllers
│   │   └── autopilot-configconnector-operator.yaml
│   └── infrastructure
│       ├── alpha-aspc-gc-ca.yaml
│       ├── alpha-phac-aspc-gc-ca.yaml
│       ├── alpha-phac-gc-ca.yaml
│       ├── api-ipa-phac-aspc-gc-ca.yaml
│       ├── api-phac-gc-ca.yaml
│       ├── beta-aspc-gc-ca.yaml
│       ├── beta-phac-aspc-gc-ca.yaml
│       ├── beta-phac-gc-ca.yaml
│       ├── canary-gc-ca.yaml
│       ├── canary-ip.yaml
│       ├── data-donnees-phac-aspc-gc-ca.yaml
│       ├── data-phac-gc-ca.yaml
│       ├── donnees-aspc-gc-ca.yaml
│       ├── ipa-aspc-gc-ca.yaml
│       ├── kustomization.yaml
│       ├── open-ouvert-phac-aspc-gc-ca.yaml
│       ├── open-phac-gc-ca.yaml
│       └── ouvert-aspc-gc-ca.yaml
└── README.md
```

# Setup

## Infrastructure

The infrastructure required for this application is expressed in the `./infra-deployment-scripts/cloud-shell-infra-init.sh` from the root of this repo.

## Application

Once the infrastructure is ready, connect to the cluster with:

```sh
gcloud container clusters get-credentials php-01hhmj81fhp-phac-dns --region northamerica-northeast1 --project php-01hhmj81fhp
```

Run the following command to bootstrap the application on the cluster:

```sh
flux bootstrap git \
    --url=ssh://git@github.com/PHACDataHub/phac-dns \
    --path=k8s/clusters/gke \
    --branch=main \
    --components="source-controller,kustomize-controller"
```

> The above command might generate and ask you to add deploy keys to the project. See [this](https://fluxcd.io/flux/cmd/flux_bootstrap/) for more information about `flux bootstrap`.

## Maintenance

## Upgrading Flux

To [upgrade flux](https://fluxcd.io/flux/installation/upgrade/) on the cluster, first make sure you have the latest [Flux CLI](https://fluxcd.io/flux/cmd/). Run the following command from the root of this repository and submit a PR with changes:

```sh
flux install \
  --components="source-controller,kustomize-controller" \
  --export > ./k8s/clusters/gke/flux-system/gotk-components.yaml
```

Once the PR is merged, Flux will propagate the changes. 

> See the [official releases](https://github.com/fluxcd/flux2/releases) page for more information regarding an upgrade.

## Upgrading KCC

To [upgrade config connector](https://cloud.google.com/config-connector/docs/how-to/install-manually#upgrading) on the cluster, run the following commands from the root of this repository and submit a PR with changes:

```sh
gsutil cp gs://configconnector-operator/<VERSION>/release-bundle.tar.gz - | tar xvzf - ./operator-system/autopilot-configconnector-operator.yaml
mv ./operator-system/autopilot-configconnector-operator.yaml ./k8s/components/controllers/
rm -rf operator-system
```

> Replace `<VERISON>` with a valid KCC Operator version.

Once the PR is merged, Flux will propagate the changes.

> See the [official releases](https://github.com/GoogleCloudPlatform/k8s-config-connector/releases) page for more information regarding an upgrade.

