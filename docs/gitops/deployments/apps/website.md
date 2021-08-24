# Website

Simple Jekyll-based site. See the [dedicated documentation](../../../../website/) for details.

The deployment of the main site is simple, making use of the dedicated Helm chart. Flux2 image automation is used to
automatically ensure that the latest website changes are deployed as soon as possible.

## Extras

Along with the basic site, there are a few Traefik `Middleware`s which are used to add a few redirects.

- A number of www.netsoc.ie/... shortcuts exist as `redirectRegex` `Middleware`s, e.g. www.netsoc.ie/cli/ ->
  github.com/netsoc/cli/releases/latest
- A redirect for netsoc.ie to www.netsoc.ie
- A redirect for any unknown subdomain of netsoc.tcd.ie to netsoc.ie (e.g. www.netsoc.tcd.ie to www.netsoc.ie)
