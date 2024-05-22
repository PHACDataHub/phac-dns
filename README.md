# phac-dns

## What & Why

We are modernizing our data management at the Public Health Agency of Canada (PHAC) by implementing a DNS repository that allows for PHAC-controlled DNS delegation. This initiative includes a self-service system for naming data services and web properties, ensuring easy access and management. Furthermore, we have introduced a tiered naming system to reflect the maturity of our Data Science Teams (DST). Central to this modernization is our "As Data" approach, which utilizes KCC YAML to describe DNS entries, facilitating automated analysis and governance across our service ecosystem. This method enhances the efficiency and oversight of our digital infrastructure, aligning with contemporary data management practices.

## Domains

The current domains we have control over are below:

### Alpha: ​​

| Domain                | Zone Ref              |
| --------------------- | --------------------- |
| alpha.phac.gc.ca​​    | alpha-phac-gc-ca      |
| alpha.aspc.gc.ca​​    | alpha-aspc-gc-ca      |
| alpha.phac-aspc.gc.ca | alpha-phac-aspc-gc-ca |

### Beta:

| Domain               | Zone Ref             |
| -------------------- | -------------------- |
| beta.phac.gc.ca​​    | beta-phac-gc-ca      |
| beta.aspc.gc.ca​​    | beta-aspc-gc-ca      |
| beta.phac-aspc.gc.ca | beta-phac-aspc-gc-ca |

### Production

| Domain                       | Zone Ref                    |
| ---------------------------- | --------------------------- |
| data.phac.gc.ca​​            | data-phac-gc-ca             |
| donnes.aspc.gc.ca​​          | donnes-aspc-gc-ca           |
| data-donnes.phac-aspc.gc.ca​ | data-donnes-phac-aspc-gc-ca |
| api.phac.gc.ca​​​            | api-phac-gc-ca              |
| ipa.aspc.gc.ca​​​            | ipa-aspc-gc-ca              |
| api-ipa.phac-aspc.gc.ca      | api-ipa-phac-aspc-gc-ca     |
| open.phac.gc.ca              | open-phac-gc-ca             |
| ouvert.aspc.gc.ca            | ouvert-aspc-gc-ca           |
| open-ouvert.phac-aspc.gc.ca  | open-ouvert-phac-aspc-gc-ca |

## Request a DNS

To request a DNS, you'll need to [create a Managed Zone](https://cloud.google.com/dns/docs/zones#create_managed_zones) resource in your GCP project.

The `DNS name` field for the zone should have one of the previously mentioned subdomains as a prefix, the general convention is `<zone-name>.<sub-domain-name>.`. For instance, if my `Zone name` is `example`, then the `DNS name` could be `example.alpha.phac-aspc.gc.ca.`

> Note: The period (`.`) at the end is required to make it a FQDN (Fully Qualified Domain Name). If you're curious, _why?_ - read [this](https://jvns.ca/blog/2022/09/12/why-do-domain-names-end-with-a-dot-/).

Once done, click `Registrar Setup` in the top right corner of the `Zone details` page for your newly created zone and note down list of NS (Name Servers).

Now, submit a PR into the repo with the following template in the `dns-records` directory.

```yaml
apiVersion: dns.cnrm.cloud.google.com/v1beta1
kind: DNSRecordSet
metadata:
  name: <zone-name>
  namespace: config-control
  annotations:
    projectName: "<project-name>"
    # projectId is the unique identifier for the project associated. i.e. phx-a345f39bv23
    projectId: "ph?-1234567890"
    sourceCodeRepository: "<sourceCodeRepository>"
    # The following annotations are optional - please comment out or remove lines that are not applicable
    serviceEndpointUrls: "<comma-separated-list-of-service url endpoints>"
    containerRegistries: "<comma-separated-list-of-container-registries>"
    apmId: <apm-id>

spec:
  name: "<DNS-name>"
  type: "NS"
  ttl: <your-desired-value>
  managedZoneRef:
    external: <zone-reference-name>
  rrdatas:
    - "<name-server-1>"
    .
    .
    - "<name-server-N>"
```

In the above template, fill out the values for placeholders(`<>`):

- `<zone-name>`: Name of the resource, could be same as the Zone name that you've created.
- `<DNS-name>`: The DNS name from the previously created resource in your project. Don't forget the `.` at the end.
- `<project-name>`: Project name, spaces allowed.
- `<codeSourceRepository>`: Full url for source code repository, e.g. "https://github.com/PHACDataHub/repo-name".
- `<comma-separated-list-of-service url endpoints>`: _Optional._ i.e. Full url for API, UI, etc.
- `<comma-separated-list-of-container-registries>`: _Optional._ e.g. Artifact registry, Docker Hub for each container.
- `<apm-id>`: _Optional._ Application Project Managament ID.
- `<your-desired-value>`: Value to set for ttl (Time to Live). A good default for this is 300 but feel free to modify it. Units are in seconds.
- `<zone-reference-name>`: This should be one of the zone references for the sub-domains we have as listed in the tables above this section.
