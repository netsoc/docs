# GitHub Actions

A number of [GitHub Actions](https://docs.github.com/en/actions) workflows have been set up on the repo to add further
automation.

## Flux upgrade automation

By running `flux install` with the same components as the `flux bootstrap` command and piping the output into
`flux/flux-system/gotk-components.yaml`, it's easy to upgrade Flux. The workflow at `.github/workflows/flux.yaml` does
this periodically and opens a pull request if any changes were detected (i.e. something was updated).

## `HelmRelease` `registryUrl` generation

In order for Renovate to be able to detect the Helm repository a `HelmRelease` references, a comment is required (which
will later be matched against with a regex by Renovate). k8s-at-home created
[an Action](https://github.com/k8s-at-home/renovate-helm-releases) which automates this process. This workflow runs on
a schedule.

## Renovate

While not technically a GitHub Action (it runs independently as a GitHub App),
[Renovate](https://github.com/marketplace/renovate) is a tool which automatically scans a repo and opens pull requests
to update dependencies. It has been configured for the GitOps repo primarily to update `HelmRelease`s. The configuration
is a at `.github/renovate.json5`.

To view logs of Renovate runs, visit [the dashboard](https://app.renovatebot.com/dashboard).

### Setup

1. Install the [Renovate GitHub app](https://github.com/apps/renovate)
2. Make sure any `HelmRelease`s use the following format for the `.spec.chart.spec`:

    ```yaml
    apiVersion: helm.toolkit.fluxcd.io/v2beta1
    kind: HelmRelease
    metadata:
      name: traefik
    spec:
      interval: 5m
      chart:
        spec:
          chart: traefik
          version: 9.19.0
          sourceRef:
            kind: HelmRepository
            name: traefik
            namespace: flux-system
    ```

(The important part is that `chart` and `version` are together at the top of the YAML object so that Renovate and the
`registryUrl` comment generator Action will detect the values correctly.
