# Longhorn

[Longhorn](https://longhorn.io/docs/) is a distributed block storage system for Kubernetes. It stores replicas of
volumes in files on disk (in
`/var/lib/longhorn` by default) and attaches them to nodes using iSCSI (frontends as block devices in `/dev/longhorn`).
The UI is accessible at [longhorn.netsoc.tcd.ie](https://longhorn.netsoc.tcd.ie), where volumes can be managed.

## Backups

Longhorn has quite an effective [backup system](https://longhorn.io/docs/1.1.2/concepts/#3-backups-and-secondary-storage).
Currently, the backup target is set to dev's home server via S3 (a MinIO server).

## Mounting a volume on a host

1. Go to the "Volume" page in the Longhorn UI
2. Attach the volume to a host (it must be detached from any workloads first)
3. SSH into the host where the volume has been attached
4. Find the volume by its name under `/dev/longhorn` and mount it
