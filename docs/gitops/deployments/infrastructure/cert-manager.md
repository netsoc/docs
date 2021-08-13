# cert-manager

[cert-manager](https://cert-manager.io/) is a very convenient application that manages issuing certificates inside
Kubernetes. Through the use of a number of CRDs, cert-manager will automatically create `Secret`s for use by `Ingress`
resources (and any other application). The total automation of certificates issued by ACME providers like Let's Encrypt
is particularly useful.

Deployment of cert-manager itself is fairly trivial. One important thing to note is that the CRDs are installed
separately in the `crds` `Kustomization` so that resources in `infrastructure` can be applied to the cluster. The CRDs
for cert-manager can be found as a download for each release.

Two `ClusterIssuer`s are deployed along with cert-manager: one for Let's Encrypt's staging server (issues certificates
which won't be considered valid but have much more lax API limits) and one for production. These both have DNS-01 and
HTTP-01 ACME challenge solvers. DNS-01 handles any netsoc.ie certificates, since we can directly manipulate records for
these domains via RFC2136. For any other domains (e.g. for custom webspace domains), HTTP-01 will create `Ingress`
resources. The ACME contact email is [acme@netsoc.tcd.ie](mailto:acme@netsoc.tcd.ie).

!!! note
    Wildcard certificates can only be issued via DNS-01.

## DNS-01 setup for LetsEncrypt

Follow these steps only if a key secret does not already exist. If it does, see
the [DNS deployment](../../apps/dns/) for details on importing an existing secret
key.

1. Add `dnsupdate=yes` and `allow-dnsupdate-from=` to PowerDNS' configuration
   (should be set for the `HelmRelease`)
2. Get a shell in the PowerDNS container
3. Generate a TSIG key:

```
pdnsutil generate-tsig-key cert-manager hmac-sha512
```

4. Allow updates from the Kubernetes network with the `cert-manager` key (do this
for each zone that will have certs generated):

```
pdnsutil add-meta myzone.com ALLOW-DNSUPDATE-FROM "10.42.0.0/16"
pdnsutil add-meta myzone.com TSIG-ALLOW-DNSUPDATE "cert-manager"
```

5. Create a secret with the Base64 data that's printed out (keep it encoded,
Kubernetes will double encode it, which is necessary!)

6. Add a solver like this to the LetsEncrypt Issuer:

```yaml
- dns01:
    rfc2136:
        nameserver: powerdns-udp.default
        tsigKeyName: 'cert-manager.'
        tsigAlgorithm: HMACSHA512
        tsigSecretSecretRef:
        name: powerdns-tsig
        key: cert-manager.key
```
