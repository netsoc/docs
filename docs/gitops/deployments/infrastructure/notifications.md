# Notifications

While not a "deployment" per se, notifications based on cluster reconciliation are provided via Flux v2's
[Notification Controller](https://fluxcd.io/docs/components/notification/). Currently, two `Provider`s are configured.

- GitHub status: Adds a GitHub "check" status next to each commit in the GitOps repo (one for each `Kustomization`)
- Matrix: Drops messages into a Matrix room via a Slack webhook for changes to `GitRepository`s and `Kustomization`s.
  The Notification Controller doesn't support Matrix directly, so [an adapter bot is used](https://t2bot.io/webhooks/).
  [#gitops:netsoc.ie](https://matrix.to/#/#gitops:netsoc.ie) is the room on Matrix.
