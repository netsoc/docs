# Development

The Docker Compose file in this repo will create a full IAM deployment, as described in the
[IAM documentation](../../iam/development/). Along with those components, both the frontend and backend will be deployed
with hot-reload development servers. The UI will be accessible on http://localhost:3000 (the API is exposed separately
on port 4242). **Be sure to copy `public/config.js` to `config.frontend.js` and make any desired changes.**

!!! tip
    Before starting the server, you should get some Stripe test keys in order to test Stripe transaction functionality.
    The secret key should be written to `.env` in the root of the repo as `STRIPE_PRIVATE_KEY`. The public key should be
    used as the value for `STRIPE_PUBLIC_KEY` in `config.frontend.js`.

    <!-- TODO: Log in to Stripe and figure out exactly how this should be done -->
    You should also set up a webhook in the Stripe dashboard for the `/webhook` backend endpoint.

The backend
is located under the `payments_server/` subdirectory and has its own production `Dockerfile` which is Node.js-based to
run the payment API server. The root `Dockerfile` only "builds" the final JavaScript before resulting in a final image
based on nginx which serves the static files. `Dockerfile.dev` serves as a hot-reload Node.js base image for both the
frontend and backend.

This repo makes use of the `build.yaml`, `release.yaml`, `charts.yaml` and `docs.yaml` GitHub Actions workflows as
described in the [IAM documentation](../iam/development/#github-actions). Note that `build.yaml` and `release.yaml` are
building two separate Docker images in this case: one for the frontend and one for the backend.

## Maintenance

- New releases should be made in the same manner as for IAM (the `release.yaml` workflow)
- When upgrading Node.js, keep in mind that the `Dockerfile`, `Dockerfile.dev` and `payments_server/Dockerfile` all need
  to be update individually
