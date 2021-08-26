# Gitea

[Gitea](https://gitea.io/) is a lightweight hosted Git service. It's set up on [git.netsoc.ie](https://git.netsoc.ie)
and supports SSO with Netsoc via dex. `gitea_admin` is the only user with admin access. The password for this account is
stored in the password manager.

Note that in order to co-locate HTTP(S) _and_ SSH for Git cloning on git.netsoc.ie, a separate IP address
(134.226.83.103) is used, with a `metallb.universe.tf/allow-shared-up` sharing key of `git`. In order to get HTTP(S)
via Traefik on this IP, a separate `LoadBalancer` service exists at `infrastructure/kube-system/traefik/git-http.yaml`.

## iamd SSO

In order to set up iamd-based SSO, a Gitea OAuth2 "Authentication Source" should be configured in the
"Site Administration" section of Gitea. A corresponding `staticClient` should be added to the dex config.

![Gitea iamd SSO](../../../assets/gitea_sso.png)
