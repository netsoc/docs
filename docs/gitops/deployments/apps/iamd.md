# iamd

iamd is Netsoc's IAM service. See [the dedicated documentation](../../../../iam/) for more details.

The deployment is fairly straightforward.

- `postgresql.soft_delete` is disabled so that deleted accounts are permanently deleted
- Accounts unverified after 72 hours will be deleted
- The ma1sd REST API endpoints are enabled
