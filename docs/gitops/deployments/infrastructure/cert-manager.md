# cert-manager

## DNS-01 setup for LetsEncrypt

Follow these steps only if a key secret does not already exist. If it does, see
the [DNS deployment](../apps/dns/) for details on importing an existing secret
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
