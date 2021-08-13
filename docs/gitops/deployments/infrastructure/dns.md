# DNS

[PowerDNS](https://www.powerdns.com/auth.html) is used to provide authoritative DNS resolution for netsoc.tcd.ie and
netsoc.ie, along with reverse DNS for `134.226.83.0/24` and our IPv6 prefix (currently unused). Maths' nameserver
ns.maths.tcd.ie will also respond to queries for netsoc.tcd.ie, so AXFRs are allowed from all of `134.226.0.0/16`.

The deployment uses a PostgreSQL database for persistence and exposes
[PowerDNS-Admin](https://github.com/ngoduykhanh/PowerDNS-Admin) at [pdns.netsoc.tcd.ie](https://pdns.netsoc.tcd.ie) for
record management. Once past basic auth, the credentials are `root:hunter22`.

## From scratch

### PowerDNS-Admin

1. Once everything is up and running, create a `root` account in PowerDNS-Admin
2. Set the "PDNS API URL" to `http://powerdns-webserver:8081`
3. Paste the API key from `secrets/powerdns.yaml`
4. Enable the SOA and ALIAS record types in _Settings_

### PowerDNS

These steps assume there is an existing TSIG key (see the
[cert-manager deployment](../infrastructure/cert-manager/)).

1. Get a shell in the PowerDNS container
2. Import the TSIG key:

The key should already exist in Git. To import it, first descrypt the
SOPS-encrypted file:

```
sops -d infrastructure/cert-manager/letsencrypt/secrets/pdns-cert-manager.key
```

Then import it in a PowerDNS shell:

```
pdnsutil import-tsig-key cert-manager hmac-sha512 "THEKEY"
```

3. Allow updates from the Kubernetes network with the `cert-manager` key (do this
for each zone that will have certs generated):

```
pdnsutil add-meta myzone.com ALLOW-DNSUPDATE-FROM "10.42.0.0/16"
pdnsutil add-meta myzone.com TSIG-ALLOW-DNSUPDATE "cert-manager"
```
