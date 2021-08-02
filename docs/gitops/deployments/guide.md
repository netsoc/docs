# Guide

This subsection describes each of the applications deployed and anything specific to a given deployment.

## Recommended structure

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
