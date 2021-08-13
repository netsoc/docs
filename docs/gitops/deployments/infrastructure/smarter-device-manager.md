# smarter-device-manager

[smarter-device-manager](https://gitlab.com/arm-research/smarter/smarter-device-manager) is a Kubernetes
[device plugin](https://kubernetes.io/docs/concepts/extend-kubernetes/compute-storage-net/device-plugins/) which allows
Linux device nodes (in `/dev` on the host) to be individually attached to containers. This model removes the need to
set `privileged: true` on a container that does not need such a level of host access.

Currently, the configuration simply makes `/dev/kvm` available to any pod that requests it by putting
`smarter-devices/kvm: 1` into container resource limits. (`nummaxdevices` is set to 110 since `/dev/kvm` isn't a
"limited resource" and 110 is the maximum number of pods that can be scheduled on a single node).
