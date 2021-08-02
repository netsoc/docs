# Cluster bootstrap

In order to bootstrap a cluster, install Kubernetes across all nodes as desired. For example, follow the
[instructions as part of the infrastructure provisioning docs](../../infrastructure/provisioning/node/#kubernetes-node).

## Temporary deployment adjustments

Before bootstrapping Flux, **which will immediately begin deploying the entire Netsoc stack**, it is recommended
that you disable the majority of the deployments and re-enable them gradually to ensure everything works as
expected.

Some examples:

- Suspend Flux resources (such as `Kustomization`s and `HelmRelease`s by adding `suspend: true` to their `spec:`).
  A good choice might be to suspend the entire `apps` `Kustomization` until the smaller `infrastructure` has been
  manually verified to be in a good state.
- Comment out specific `resources:` in `kustomization.yaml` files to avoid applying them to the cluster at all

## Installation

Once all of your nodes are joined:

1. [Install the Flux CLI](https://fluxcd.io/docs/installation/#install-the-flux-cli)
2. Export a [GitHub personal access token](https://docs.github.com/en/github/authenticating-to-github/keeping-your-account-and-data-secure/creating-a-personal-access-token)
   with access to [netsoc/gitops][repo] in `GITHUB_TOKEN`
3. Import the Netsoc PGP key into the cluster (for [secrets decryption](./sops/)):

    ```
    gpg --export-secret-keys --armor {{ pgp_key }} | kubectl -n flux-system create secret generic pgp --from-file=git.asc=/dev/stdin
    ```

4. Install Flux and begin cluster reconciliation:

    ```
    flux bootstrap github --components-extra=image-reflector-controller,image-automation-controller --owner=netsoc --repository=gitops --read-write-key --branch=main --path flux --private=false --reconcile
    ```

5. Once this command completes successfully, all of the Flux components are installed and changes to the cluster should
   generally only be made by editing manifests in Git and allowing Flux to reconcile the cluster

    !!! tip
        The `flux reconcile` subcommands can be used to request Flux immediately reconcile objects, for example
        `flux reconcile kustomization --with-source infrastructure` will have Flux reconcile the source object
        referenced by the `Kustomization` `infrastructure` and then reconcile the `Kustomization` itself.

6. At this point, you should create all of the volumes required by deployments in the Longhorn UI at
   [longhorn.netsoc.tcd.ie](https://longhorn.netsoc.tcd.ie). You can get a list of all `PersistentVolume`s that need
   corresponding Longhorn volumes (and their capacities) by running `kubectl get pv`. See
   [here](../deployments/infrastructure/longhorn/) for more details.

## Upgrades

Updates to Flux components are done automatically via a GitHub Actions workflow (by opening a PR with the updated
components), see [here](../actions/) for details.

[repo]: https://github.com/netsoc/gitops
