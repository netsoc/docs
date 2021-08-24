# Introduction

`website-ng` is a fairly simple Jekyll-based website. Any content changes pushed to `master` are automatically built
as a Docker image and deployed to [www.netsoc.ie](https://www.netsoc.ie). A Helm chart is provided for Kubernetes
deployment (refer to [our charts repo](https://github.com/netsoc/charts)).

## Development

A Docker Compose file with hot-reload is provided. The site can then be viewed at http://localhost:4000. `build.yaml`,
`charts.yaml` and `docs.yaml` GitHub Actions workflows are used for CI and function as described in
[the IAM documentation](../iam/development/#github-actions).

## Maintenance

- To upgrade Jekyll, edit both `docker/Dockerfile` _and_ `docker/Dockerfile.dev`
