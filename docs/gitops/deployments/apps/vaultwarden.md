# Vaultwarden

[Vaultwarden](https://github.com/dani-garcia/vaultwarden) is an (unofficial) lightweight implementation of Bitwarden's
API, providing the same web UI as the official deployment. It is available at
[pass.netsoc.tcd.ie](https://pass.netsoc.tcd.ie) (for sysadmins only). Passwords should be stored in the "Netsoc"
organisation, but each admin should have their own account.

## Adding users

Access the Vaultwarden admin dashboard at [pass.netsoc.tcd.ie/admin](https://pass.netsoc.tcd.ie/admin). The admin token
is stored as a secret `ADMIN_TOKEN` in `secrets/values.yaml` From the dashboard, new users can be invited by email.
