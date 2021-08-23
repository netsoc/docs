# DNS

[PowerDNS](https://www.powerdns.com/auth.html) is used to provide authoritative DNS resolution for netsoc.tcd.ie and
netsoc.ie, along with reverse DNS for `134.226.83.0/24` and our IPv6 prefix (currently unused). Maths' nameserver
ns.maths.tcd.ie will also respond to queries for netsoc.tcd.ie, so AXFRs are allowed from all of `134.226.0.0/16`.

The deployment uses a PostgreSQL database for persistence and exposes
[PowerDNS-Admin](https://github.com/ngoduykhanh/PowerDNS-Admin) at [pdns.netsoc.tcd.ie](https://pdns.netsoc.tcd.ie) for
record management. Once past basic auth, the credentials are `root:hunter22`.

## Domains

### netsoc.tcd.ie

We have delegeated authority over netsoc.tcd.ie. The nameservers (according to `auth-ns*.tcd.ie`) are:

- ns1.netsoc.tcd.ie
- ns2.netsoc.tcd.ie
- ns3.netsoc.tcd.ie
- ns.maths.tcd.ie

As ns1.netsoc.tcd.ie points to 134.226.83.27, this is the primary `LoadBalancer` IP that is used for PowerDNS. As
ns2.netsoc.tcd.ie points to 134.226.83.42, `shoe` will DNAT external DNS traffic to 134.226.83.27. ns3.netsoc.tcd.ie
does not currently resolve. Maths' nameserver will perform AXFR requests to keep its copy of netsoc.tcd.ie up to date.

For what are assumed to be legacy reasons, both IPv4 and IPv6 reverse DNS zones have different name-based NS records.
Refer to the notes on A records for these in PowerDNS-Admin for more details.

### netsoc.ie

This domain is registered with [HostingIreland](https://www.hostingireland.ie/) (credentials in password manager). Due
to a strange issue with .ie domains, where it appears that a .ie cannot be a nameserver for another .ie domain (e.g. for
netsoc.ie to use {ns1,ns2}.netsoc.tcd.ie for its nameservers), dev has set up temporary records that point to the real
Netsoc nameservers and used those instead. HEAnet should be able to resolve this (in theory).

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
