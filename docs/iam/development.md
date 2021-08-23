# Development

A Docker Compose file is provided, simply `docker-compose up` to get a working iamd from source (including a database
and email server). The API will be served on http://localhost:8080. MailSlurper (mock email) can be accessed on
http://localhost:8181. Any changes to the sources will automatically trigger a rebuild.

## GitHub Actions

There are a number of GitHub Actions workflows which automate various aspects of deployment:

- `build.yaml`: Runs tests and coverage (publishing results to Testspace) before building and pushing a multi-arch
  Docker image to ghcr.io/netsoc/iamd (tags `latest` and `<git_shortref>-<unix_time>Z`, e.g. `fcab5f1b-1626988684Z`).
  Executed on every push to `master`
- `release.yaml`: Executed on pushing of a `v*` tag. Re-tags the latest Docker image to match the version. **Release
  tags _must_ follow [Semantic Versioning](https://semver.org/) prefixed with `v`, e.g. `v1.2.3`**.
- `generate.yaml`: Uses [OpenAPI Generator](https://openapi-generator.tech/) to generate a JavaScript and Go
  client for the IAM REST API (when `static/api.yaml` changes). The JavaScript client is pushed to NPM as
  [@netsoc/iam](https://www.npmjs.com/package/@netsoc/iam) and the Go client is available at
  [github.com/netsoc/iam/client](https://pkg.go.dev/github.com/netsoc/iam/client)
- `charts.yaml`: Executes on changes to the chart (in the `charts/` directory). **Updating the `version` in
  `Chart.yaml` will effectively release the chart as the automation in the charts repo will detect and
  update the Helm repo**
- `docs.yaml`: Pushes changes to documentation to the central docs repo

## Maintenance

- To make a new release, first push all changes and _wait for the tests to pass and the build to complete_. You can then
  push a new **semver-formatted prefixed with a `v`**, e.g. v1.2.3. You should then update `appVersion` in `Chart.yaml`
  (and increment the chart's own `version` as well).
- To upgrade the Go version, edit go.mod and update the base Docker image in _both_ `Dockerfile`
  and `Dockerfile.dev`. The `go-version` should also be updated in `build.yaml` for test runs.

!!! warning
    Currently, upgrading GORM seems to break tests (presumably SQL queries are issued in a slightly different manner
    under the hood)
