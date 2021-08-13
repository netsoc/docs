# Traefik

[Traefik](https://doc.traefik.io/traefik/) is a Go-based HTTP (and TCP) reverse proxy. It acts as the primary
[ingress controller](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/) for all of our
HTTP(S) traffic.

The basic deployment of Traefik uses a `LoadBalancer` service running on 134.226.83.100. The `externalTrafficPolicy` is
`Local` as to keep the original source IP of traffic. The Traefik dashboard is accessible at
[traefik.netsoc.tcd.ie](https://traefik.netsoc.tcd.ie).

Note that [kubelan](https://github.com/devplayer0/kubelan) is implemented as a sidecar for routing requests to
webspaces. See the [webspaces](../../apps/webspaces/) deployment for more details.

## TLS

### netsoc.tcd.ie

A wildcard certificate is issued for `netsoc.tcd.ie` is issued by IT Services. For every namespace where this
certificate is used, a suitable `Secret` is generated with a `Kustomize` `secretGenerator` from the original certificate
and key (in the root `kustomization.yaml` for `infrastructure`).

### netsoc.ie

cert-manager `Certificate` objects are created in every namespace where a netsoc.ie certificate is required.
cert-manager will then issue these using the `letsencrypt` `ClusterIssuer`.

## Basic authentication

A number of deployments expose dashboards which should not be accessible without authentication, so there is a re-usable
[`basicAuth` middleware](https://doc.traefik.io/traefik/middlewares/basicauth/) (named `auth`) which can be used to
secure any `Ingress` or `IngressRoute`.

Passwords can be generated with `openssl passwd -apr1` (or `htpasswd` as suggested in the documentation).

## Netsoc patches

The image used is built from [a fork](https://github.com/netsoc/traefik) with a patchset for Netsoc-specific
functionality in Traefik. When working on this fork, a specific addition or change should be rebased into a single
commit and onto an upstream tagged release. These patches should then exist on the `webspace-ng` branch.

!!! tip
    `make run-dev` will build and run Traefik locally.

!!! warning
    Some patches may make changes to CRDs (and affect their schemas). Run `make generate-crd` to re-generate the YAML
    definitions. **This also means that the CRDs generated from this fork should be used over those provided upstream,
    either in the official repo or the Helm chart.**

### Build workflow

!!! warning
    The `TRAEFIK_VERSION` environment variable should be manually updated in `.github/workflows/build.yaml` when
    upgrading to a newer upstream release.

A workflow builds and pushes the patched Traefik image to `ghcr.io/netsoc/traefik` with tag
`<upstream_version>-<git_sha>`, for example `2.5.0-rc2-5be7f6a2`.

### webspaced middleware

In order to catch requests to webspaces that are shut down and wait for them to start, custom middleware (both HTTP and
TCP) has been implemented. Under normal circumstances this middleware should never be created by hand (it should be
managed by webspaced). Below is a sample of the configuration (the same for HTTP and TCP):

```yaml
webspaceBoot:
  # Netsoc IAM token used to authenticate against webspaced (should be admin)
  iamToken: a.b.c
  # Base URL of Netsoc webspaced API (_excluding version, only the internal API is used_)
  url: https://webspaced.netsoc.ie
  # ID of user whose webspace should be booted
  userID: 123
```

This patch is implemented to modify as little core Traefik code as possible. Both HTTP and TCP variants (TCP being for
TLS passthrough) use the middleware interface provided by Traefik (TCP middleware being added in Traefik 2.5).
