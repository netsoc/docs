# Guide

This subsection describes each of the applications deployed and anything specific to a given deployment. On this page
you'll find general recommendations about how common deployment elements should be handled.

## File structure

Below is an abridged tree of the GitOps repo, highlighting suggested deployment structuring.

- Each top-level directory should correspond to a `Kustomization` (as described [here](../../))
- Subdirectories of top-level `Kustomizations` should generally be the name of a corresponding namespace (e.g.
  `apps/default`, `apps/webspaces`, `infrastructure/metallb-system`)
- A namespace directory should contain a `_namespace.yaml` file with a Kubernetes `Namespace` defintion (if it does not
  already exist elsewhere). See `infrastructure/longhorn-system/_namespace.yaml` for an example.
- A deployment which contains only a single object (e.g. a `HelmRelease`) and no other files (secrets, etc.) can be
  placed directly into a namespace directory named as `<deployment>.yaml`. See `apps/default/docs.yaml` for an
  example.
- Any deployment which requires additional objects or files should have its own subdirectory, e.g. `apps/default/iamd/`.
  Resources in this folder should generally be named by the type of resource they contain, e.g. `helm.yaml` if the YAML
  is a `HelmRelease`, or `pvc.yaml` for `PersistentVolumeClaim`s.
- Secret values should generally be used in their original form and translated into Kubernetes objects via
  `secretGenerator` (instead of creating encrypted `Secret` manifests)
- Secrets should be placed in a subdirectory `secrets/`, such as `apps/default/iamd/secrets/`
- CRDs which are needed by other `Kustomization`s should be placed under `crds/` and contain the version in the filename
- `ImagePolicy`s and their associated `ImageRepository`s should be placed in `flux/images/`

```
gitops
├── apps
│   ├── default
│   │   ├── accounts
│   │   │   └── ...
│   │   ├── docs.yaml
│   │   ├── iamd
│   │   │   ├── helm.yaml
│   │   │   ├── kustomization.yaml
│   │   │   ├── pvc.yaml
│   │   │   └── secrets
│   │   │       └── values.yaml
│   │   ├── kustomization.yaml
│   │   ├── shhd
│   │   │   ├── helm.yaml
│   │   │   ├── kustomization.yaml
│   │   │   └── secrets
│   │   │       ├── host.key
│   │   │       └── iam_token.bin
│   │   ├── tls-main.yaml
│   │   └── ...
│   ├── extra
│   │   ├── gitea
│   │   │   └── helm.yaml
│   │   └── ...
│   ├── kustomization.yaml
│   ├── namerefs.yaml
│   └── webspaces
│       └── ...
├── crds
│   ├── cert-manager-v1.4.0.yaml
│   └── traefik-v2.5.0-rc2-netsoc.yaml
├── docs
│   └── ...
├── flux
│   ├── apps.yaml
│   ├── flux-system
│   │   ├── gotk-components.yaml
│   │   ├── gotk-sync.yaml
│   │   └── kustomization.yaml
│   ├── helm-repos
│   │   ├── ananace.yaml
│   │   ├── bitnami.yaml
│   │   └── ...
│   ├── images
│   │   ├── kustomization.yaml
│   │   ├── netsoc
│   │   │   ├── docs.yaml
│   │   │   ├── kustomization.yaml
│   │   │   └── website.yaml
│   │   └── update.yaml
│   ├── infrastructure.yaml
│   └── kustomization.yaml
├── infrastructure
│   ├── cert-manager
│   │   └── ...
│   ├── common
│   │   ├── netsoc.tcd.ie.crt
│   │   └── netsoc.tcd.ie.key
│   ├── extra.yaml
│   ├── kustomization.yaml
│   ├── longhorn-system
│   │   ├── kustomization.yaml
│   │   ├── longhorn.yaml
│   │   └── _namespace.yaml
│   ├── namerefs.yaml
│   └── ...
└── README.md
```

## `LoadBalancer` services

When creating a `LoadBalancer` service, please consider the caveats
[as described in the MetalLB deployment](../infrastructure/metallb/). You'll also need to update the rules for
[Kubewall](../infrastructure/kubewall/).

## Secrets

### `secretGenerator` naming

Using Kustomizes' `secretGenerator` (and indeed `configMapGenerator`) feature adds a hash to the end of the final object
name. While Kustomize will detect references to secrets in common scenarios and append the hash automatically, this is
not the case for custom resources or Helm values.

This behaviour can be disabled by setting `options.disableNameSuffixHash=true` to the `secretGenerator` or
`configMapGenerator`. See [here](https://github.com/kubernetes-sigs/kustomize/blob/master/examples/generatorOptions.md)
for more details. This is the approach to take if the path is unstructured, i.e. a reference in Helm values.
Alternatively, if the reference is at a common path, a you can add custom `nameReference`s. See
[here](https://github.com/kubernetes-sigs/kustomize/blob/master/examples/transformerconfigs/README.md#name-reference-transformer)
for details and `infrastructure/namerefs.yaml` for an example. The `namerefs.yaml` should be referenced in the
top-level `kustomization.yaml` under the `configurations` array.

### `HelmRelease` values overrides

It's often convenient to take advantage of the Helm Controller's
[values overrides feature](https://fluxcd.io/docs/components/helm/helmreleases/#values-overrides), which is especially
handy when combined with SOPS encryption. It's important to keep an eye on newlines when using this method. If a target
field is newline-sensitive (e.g. a password), the referenced file should probably **not** end with a newline. Text
editors will commonly append a trailing newline to files on save, so check with a Hex editor before encrypting. Using a
`.bin` extension (even for text) can help to semantically reinforce this.

## Storage

In Kubernetes, persistent storage is typically allocated automatically through the use of `PersistentVolumeClaim`s and
a dynamic storage provisioner. While this is convenient, it's better in this case to pre-create a Longhorn volume, a
`PersistentVolume` referencing the volume and a `PersistentVolumeClaim` that explicitly references the PV. Roughly
following the guide [here](https://longhorn.io/docs/1.1.2/snapshots-and-backups/backup-and-restore/restore-statefulset/),
you can create the following YAML:

```yaml
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: my-vol
spec:
  volumeMode: Filesystem
  accessModes: [ReadWriteOnce]
  capacity:
    storage: 2Gi
  storageClassName: longhorn
  csi:
    driver: driver.longhorn.io
    volumeHandle: iamd-postgresql
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-vol
spec:
  volumeMode: Filesystem
  accessModes: [ReadWriteOnce]
  resources:
    requests:
      storage: 2Gi
  volumeName: iamd-postgresql
  storageClassName: longhorn

```

Note that the underlying Longhorn volume referenced by `csi.volumeHandle` in the `PersistentVolume` should either
already exist or be created afterwards in the Longhorn UI.

Many Helm charts will allow you to specify an `existingClaim` when configuring persistence (such as
[Bitnami's PostgreSQL chart](https://github.com/bitnami/charts/tree/master/bitnami/postgresql)) and will then avoid
creating their own claims. For `StatefulSets` with multiple replicas, the name of the volume is generated by Kubernetes.
In this case you should establish the template and can pre-create the PVCs manually. Kustomize will re-order its output
so that PV(C)s will be created before workloads and `StatefulSet` will pick them up if named correctly.

## Image update automation

Flux2 [provides](https://fluxcd.io/docs/components/image/) automated updates for YAML files referencing Docker images.
Setting this up is fairly easy. Below is an example of the components needed to automate updates for an image whose
tag format is `<git_shortref>-<unix_time>Z`:

```yaml
---
apiVersion: image.toolkit.fluxcd.io/v1beta1
kind: ImageRepository
metadata:
  name: website
spec:
  # The image to poll for updates
  image: ghcr.io/netsoc/website
  interval: 1m0s
---
apiVersion: image.toolkit.fluxcd.io/v1beta1
kind: ImagePolicy
metadata:
  name: website
spec:
  # Reference the image we would like to automate
  imageRepositoryRef:
    name: website
  filterTags:
    # Extract the timestamp from the tag with a regex and sort by that value
    pattern: '^[a-fA-F0-9]{8}-(?P<time>\d+)Z$'
    extract: '$time'
  policy:
    numerical:
      order: asc

```

Wherever you would like to reference the automated image, you should add a special YAML comment at the end of the line.
Available formats and examples are described
[here](https://fluxcd.io/docs/guides/image-update/#configure-image-update-for-custom-resources).

!!! tip
    In order to actually apply the updates, an `ImageUpdateAutomation` is required. See `flux/images/update.yaml` for
    the one used to commit updates into Git.
