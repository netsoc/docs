# Introduction

This documentation site is based on [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/). Similar to
[the main www.netsoc.ie site](../website/), any changes pushed to `master` are automatically deployed to the live site
at [docs.netsoc.ie](/). Most of the content actually comes from other individual repos under a `docs/` subdirectory.
Whenever changes are made to these repos' docs, they are pushed into the central docs repo.

## Development

The Docker Compose file sets up a hot-reload development server. The site can be viewed at http://localhost:8000. The
docs repo uses the `build.yaml` and `charts.yaml` GitHub Actions workflows as described in
[the IAM documentation](../iam/development/#github-actions).

!!! warning
    To simulate the latest copies of documentation being pushed in the development environment, every individual repo is
    mounted separately into the container. This means that you **must** have all of the following repos cloned into the
    same directory as the docs repo:

    - [netsoc/cli]({{ github_org }}/cli)
    - [netsoc/webspaced]({{ github_org }}/webspaced)
    - [netsoc/shh]({{ github_org }}/shh)
    - [netsoc/infrastructure]({{ github_org }}/infrastructure)
    - [netsoc/gitops]({{ github_org }}/gitops)
    - [netsoc/iam]({{ github_org }}/iam)
    - [netsoc/website-ng]({{ github_org }}/website-ng)

## Maintenance

- When upgrading the Python version used to build the site, be sure to update both `Dockerfile` _and_ `Dockerfile.dev`
