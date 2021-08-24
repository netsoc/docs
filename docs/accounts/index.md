# Introduction

A Vue.js-based web UI for managing [iamd](../iam/)-based user accounts, including processing payments for account
renewals via Stripe. There is actually a small backend component which is responsible for validating Stripe transactions
and using the IAM REST API to update user renewal status.

## Managing your account

To manage your account, visit the live deployment of the accounts UI at
[accounts.netsoc.ie](https://accounts.netsoc.ie). Most common account management tasks should be fairly
self-explanatory, but if you have any issues, feel free to [contact us](../contact/).

## Deployment

The UI and backend should generally be deployed via Helm chart. Be sure to set the `config.STRIPE_PUBLIC_KEY` on the
frontend along with `secrets.stripePrivateKey` and `secrets.stripeEndpointSecret` in your values.
