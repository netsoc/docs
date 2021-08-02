# SOPS

[Mozilla SOPS](https://github.com/mozilla/sops) allows for the encryption of secret values in YAML and other files.
When YAML or JSON is being encrypted, specific keys can be encrypted.

## PGP key generation

Make sure _not_ to use a passphrase.

```bash
gpg --generate-key
```

Be sure to update the public key fingerprint in .sops.yaml at the root of the repo.

## Create a secret and encrypt it

In order to decrypt data within a `Kustomization`, it must first be
[configured for SOPS decryption](https://fluxcd.io/docs/components/kustomize/kustomization/#openpgp).

### Using Kustomize

When a `Kustomization` is configured for decryption, even regular
files referenced in `kustomization.yaml` files (e.g. for `secretGenerator`) will be decrypted automatically when Flux
attempts reconciliation.

```
sops -e --in-place my-secret.txt
```

### Directly as a Kubernetes object

```bash
kubectl -n my-namespace create secret generic my-secret --from-literal=password=hunter2 --dry-run=client -o yaml | \
    sops -e --encrypted-regex '^data$' --input-type yaml --output-type yaml /dev/stdin > \
    my-secret.yaml
```
