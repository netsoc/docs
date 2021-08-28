# Webspaces

Netsoc's next-gen LXD container-based webspaces are the main service offered by Netsoc. The deployment is made up of a
number of custom components:

- [kubelan](https://github.com/devplayer0/kubelan): A VXLAN-based overlay solution that allows all of the components to
  talk to each other (and individual containers) directly on a private Layer 2 LAN
- [lxd8s](https://github.com/devplayer0/lxd8s): Solution for running LXD inside Kubernetes pods
- [kuberouter](https://github.com/devplayer0/kuberouter): kuberouter (formerly dnsmasq-k8s) provides a router
  implementation for the private LXD network
- [OctoLXD](https://github.com/devplayer0/OctoLXD): Simple proxy that implements the LXD `simplestreams` protocol for
  image servers by parsing GitHub releases in [Netsoc's lxd-images repo](https://github.com/netsoc/lxd-images)
- [webspaced](../../../../webspaced/): The main glue for webspaces. It exposes the API that allows users to manage
  their container, generates Traefik configuration and handles port forwarding.

## kubelan

By default lxd8s, kuberouter and webspaced generate their own `ConfigMap` to configure kubelan. Since these components
share a common network, a custom `ConfigMap` `kubelan` is created (via a `configMapGenerator` in the `webspaces`
`kustomization.yaml`). This is then applied via `global.kubelan.externalConfigMap`.

[Traefik's deployment](../../infrastructure/traefik/) uses the `additionalContainers` section of the `deployment` to
add kubelan as a sidecar. **In order to update the kubelan configuration, you should edit `apps/webspaces/kubelan.yaml`
and the environment variables for the Traefik sidecar.**

## lxd8s

### Resource allocation

Since each of the nodes in our Kubernetes cluster have different resource allocations, percentage-based sizing is used
to allocate vCPUs and memory.

### Storage

Both the LXD and LXD storage volumes are also only created with 2 replicas, since the storage volumes in particular
are very large.

!!! warning
    Be careful when upgrading lxd8s. If the pods are rescheduled onto different nodes than before, Longhorn will start
    syncing a replica onto the node if it doesn't already exist (data locality). While this won't prevent the pods from
    starting, IO performance will be extremely poor during this process.

### LXD considerations

- The `preseed` value in the deployment for lxd8s only applies when the cluster is being initialised from scratch. To
  edit parameters in an existing deployment, use the `lxc` tool.
- When an lxd8s upgrade includes an LXD update, you might need to set `enableProbes` to `false`. This is because LXD
  will wait until all cluster members are online before upgrading the database. You should set `enableProbes` back to
  `true` once the upgrade completes successfully.
- To import new images, use `lxc image copy --auto-update --alias <image_name> <remote>:<image_name> local:`. LXC
  remotes are stored client side, so you might need to
  `lxc remote add netsoc https://octolxd.netsoc.ie/netsoc/lxd-images --protocol simplestreams` first if importing a
  Netsoc image.

### Public endpoint

For convenience, LXD is accessible remotely at [https://lxd.netsoc.tcd.ie:8443](https://lxd.netsoc.tcd.ie:8443). LXD
gets its own port as it likes to handle its own TLS connections. In order to connect from your `lxc`, you'll need to
first `lxc config trust import` your `~/.config/lxc/client.crt`.

!!! note
    Because of the separate port, an extra `ports:` entry is added to the Traefik deployment. This is referenced in
    `ingressRoute.entryPoints` in the lxd8s `HelmRelease`.

## kuberouter

kuberouter (located under `apps/webspaces/dnsmasq/`) provides DHCP and a NAT firewall for LXD containers. The network
for the LAN is `172.24.0.0/16`. The following static IPs are used in the network:

- `172.24.254.1`: kuberouter itself
- `172.24.0.254`: Traefik
- `172.24.0.x`: Each lxd8s replica (0 uses `172.24.0.1`, 1 uses `172.24.0.2` etc.))
- `172.24.254.2`: webspaced

## OctoLXD

OctoLXD is usable for any GitHub repo, the remote to add to LXD is of the form `https://octolxd.netsoc.ie/<org>/<repo>`.
For Netsoc's LXD images, this would be `https://octolxd.netsoc.ie/netsoc/lxd-images`.

## webspaced

- The LXD remote server certificate is set explicitly (the `*.netsoc.tcd.ie` wildcard cert) so that the client will
  verify it directly
- Port forwards are exposed on a `LoadBalanacer` `Service` whose public IP is 134.226.83.101

!!! warning
    If LXD dies unexpectedly, it's possible for webspaced to become out of sync with webspace state (although it tries
    to detect this scenario and recover from it). You can simply delete the pod to have all state cleaned up and
    re-created. _Note that this process can take a minute or two given the number of Kubernetes resources involved._
