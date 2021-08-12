# Kubewall

[Kubewall](https://github.com/devplayer0/kubewall) is a simple daemon which watches a given
[nftables](https://wiki.nftables.org/wiki-nftables/index.php/Main_Page) rules file and applies the rules to the host
network when the file changes. It is deployed as a `DaemonSet` to ensure that traffic coming in over the WAN interface
is limited only to explicitly allowed addresses and ports.

Below is the current **live** ruleset:

```
--8<-- "docs/gitops/conf/kubewall-rules.nft"
```
