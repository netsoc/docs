# Mail web traffic

Since the mail server is hosted outside Kubernetes, an `ExternalName` service combined with an `Ingress` proxies HTTP(S)
requests to `mail.netsoc.tcd.ie` to `mail.netsoc.internal`.
