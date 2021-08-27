# Matrix

[Matrix](https://matrix.org/) is a an open standard for decentralised communication. A number of components are set up
for Netsoc's deployment:

- [ma1sd](https://github.com/ma1uta/ma1sd): A federated Matrix Identity server for
  [Netsoc IAM](../../../../iam/)-based authentication and directory
- [Synapse](https://github.com/matrix-org/synapse): The reference Matrix homeserver implementation
- [Element Web](https://github.com/vector-im/element-web): The mainstream React.js-based web client for Matrix

Element is accessible at [matrix.netsoc.ie](https://matrix.netsoc.ie) and users can sign in with their Netsoc account.
Other clients (e.g. Element on Android or iOS) should configure netsoc.ie as their homeserver when signing in.
For federation and logins to work with just "netsoc.ie" as the server's domain, SRV records are set up for
`_matrix._tcp.netsoc.ie` and `_matrix-identity._tcp.netsoc.ie` to point to `matrix.netsoc.ie:443`.

## ma1sd

ma1sd is configured with a [REST Identity store](https://github.com/ma1uta/ma1sd/blob/master/docs/stores/rest.md) that
points to iamd's implementation of the required endpoints. A Netsoc-maintained Helm chart was created to deploy ma1sd in
Kubernetes.

## Synapse

Synapse is deployed with
[Ananace's excellent Helm chart](https://gitlab.com/ananace/charts/-/tree/master/charts/matrix-synapse) and is exposed
at matrix.netsoc.ie (with some endpoints also on netsoc.ie for compatibility).

### ma1sd integration

In order to integrate ma1sd with Synapse, a number of pieces need to be in place. First, Synapse needs to be configured
with the REST password provider, which is a sort of plugin that ensures Synapse calls ma1sd to validate passwords. The
author of ma1sd links to a repo for this, but unfortunately it's broken on Synapse v1.19.0+, so dev
[forked it](https://github.com/devplayer0/matrix-synapse-rest-password-provider).
[A PR is open](https://github.com/ma1uta/matrix-synapse-rest-password-provider/pull/8) to merge the fix, but
ma1uta has not responded to it.

To set up the password provider, it needs to be installed inside Synapse containers. Some `extraCommands` are used to
achieve this by downloading and installing the plugin before the main Synapse process is started. A small block of
Synapse configuration is then used to point the REST provider at ma1sd.

For ma1sd to correctly handle authentication and directory requests, it needs to intercept a number of Matrix
API endpoints. These are described in ma1sd's documentation for each feature. These are configured under `paths` and
`csPaths`. The difference between `paths` and`csPaths` is that `csPaths` (client-server APIs) are only exposed on
matrix.netsoc.ie, whereas `paths` are also accessible at netsoc.ie.

### Workers

In order to
improve performance, a number of Synapse workers are deployed (generic, notification pusher, federation sender and
media repository). Synapse's worker system is a bit messy, but is best described
[here in the Synapse documentation](https://matrix-org.github.io/synapse/latest/workers.html).

To properly
route API requests to workers, individual paths are added to a `csPaths` array for each worker. Ananace's chart
specifies a default set based on each worker's capabilities, but in order for ma1sd's login interception to work, the
explicit `/_matrix/client/*/login` must be removed from the list. This is the reason for explicitly setting `csPaths` in
the deployment.

### Signing key

The signing key is stored in a secret. To generate a new one:
`docker run --rm --entrypoint 'sh' matrixdotorg/synapse -c generate_signing_key.py`.

## Element Web

Element is accessible at the same [matrix.netsoc.ie](https://matrix.netsoc.ie) as Matrix itself. In order to add some
custom branding to the homepage for Element, a custom `welcome.html` is mounted into the web container via a
`ConfigMap`.
