# Introduction

iamd is Netsoc's home-grown IAM (Indentity and Access Management) service. It is responsible for storing user account
details (name, email, password hash etc). iamd exposes a REST API for managing and authenticating users. This API is
well-documented as an OpenAPI spec in `static/api.yaml` in the repo.

!!! tip
    The API can be browsed and tested with the live iamd deployment by visiting
    [iam.netsoc.ie/swagger](https://iam.netsoc.ie/swagger).

User data is stored in a PostgreSQL database and authentication is based around JWTs. A second API server exists to
implement [ma1sd's REST Identity store](https://github.com/ma1uta/ma1sd/blob/master/docs/stores/rest.md). This allows
for native Matrix authentication against iamd when configured with ma1sd.

## Authentication mechanism

As mentioned above, authentication against the API (and other services) is based upon JWTs
([JSON Web Tokens](https://jwt.io/)). The structure and use of these tokens is a bit specific.

- The `sub` represents the unique, unchanging user ID (database primary key). This is so that the `username` field is
  modifiable.
- `iat` and `exp` are based on a user's `renewed` time (expiring when they should renew their account). If a user's
  account has not been renewed, _a token is still valid for certain operations_ (modifying their account, logging out).
- `version` is the "account version", which is checked against the user's value in the database. It is increased
  whenever all currently valid tokens should be immediately invalidated (e.g. a user wants to "log out" of all devices
  or change their password).
- `is_admin` is a quick way to identify if a user is an admin on the client side

Services wanting to use iamd to authenticate users can use the `/users/self/token` endpoint to validate a token and
can query information about the user with an admin token if needed.

## Deployment

The Docker repo for iamd is ghcr.io/netsoc/iamd. A Helm chart is also provided, see our
[charts repo](https://github.com/netsoc/charts).

Configuration is normally done by a YAML-formatted config file, which is generated from `config:` in the chart values.
See `config.sample.yaml` for a complete set of options. Any option can also be overridden via an environment variable
prefixed with `IAMD_`. Nested keys should be separated with an `_`, e.g. `smtp.host` becomes `IAMD_SMTP_HOST`.
