# Internals

SHH combines the [github.com/gliderlabs/ssh](https://github.com/gliderlabs/ssh) library with
[NsJail](https://github.com/google/nsjail) to provide a temporary shell that Netsoc members can use to access the CLI
without needing to install it on their own machines. NsJail is a very lightweight "containerisation" or process
isolation tool, perfect for creating a limited environment for running the Netsoc CLI. shhd uses an SSH library in order
to implement [iamd](../../iam/)-based authentication (either via password or optional SSH public key).

A Helm chart is provided for deployment (from our [charts repo](https://github.com/netsoc/charts)).

## Development

A Docker Compose file is provided that will build shhd from source. Hot-reload is not provided however; you'll need to
`docker-compose up --build` to rebuild with changes. The SSH server will be accessible on localhost:2222 (e.g.
`ssh my-user@localhost -p 2222`). Set configuration options in `config.yaml` in the repo root (see `config.sample.yaml`
for all values).

This repo makes use of the `build.yaml`, `release.yaml`, `charts.yaml` and `docs.yaml` GitHub Actions workflows as
described in [the IAM documentation](../../iam/development/#github-actions).

## Maintenance

- When upgrading Go, be sure to update both `go.mod` and the base image in the `Dockerfile`
- Whenever the CLI is updated, the `NETSOC_CLI_VERSION` variable should be updated accordingly, along with `CLI_VERSION`
  in the `build.yaml` workflow. The sample applies for the upstream NsJail image.
- New releases should be made in the same manner as for IAM (the release.yaml workflow)
