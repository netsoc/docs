# dex

[dex](https://github.com/dexidp/dex) is effectively a "proxy" exposing an OpenID Connect interface to a number of
potential identity stores (via "connectors"). In order to provide support for Netsoc IAM-based stores, a small patch
exists to add an `iamd` connector. The patched dex is at [github.com/netsoc/dex](https://github.com/netsoc/dex). dex is
accessible at [dex.netsoc.ie](https://dex.netsoc.ie/.well-known/openid-configuration).

## Netsoc patches

### `iamd` connector

The first commit on the `netsoc` branch adds the `iamd` connector (all changes should be squashed into this commit).
When a new release of dex is made upstream, the 2 commits on the `netsoc` branch should be rebased atop the release.
Below is a list of config options for the connector:

```yaml
# IAM REST API URL
url: https://iam.netsoc.ie/v1
# Admin token to get user info from IAM API
token: A.B.C
# Placeholder for dex login field
prompt: Netsoc username
```

### Build workflow

!!! warning
    The `VERSION` environment variable needs to be manually updated in `.github/workflows/docker.yaml` when upgrading to
    a newer upstream release.

The second commit replaces the upstream `docker.yaml` GitHub Actions workflow with one that pushes the built image to
ghcr.io/netsoc/dex with a tag of the form `<upstream_version>-<git_shortref>-netsoc`, e.g. `2.30.0-98ce910c-netsoc`.

## Adding clients

In order to add new clients, add a new entry to the `staticClients` section of the config (as a secret). For example:

```yaml
staticClients:
  - id: gitea
    name: Gitea
    redirectURIs:
      # Specified by the application
      - http://git.netsoc.ie/user/oauth2/netsoc/callback
    secret: hunter22
```
