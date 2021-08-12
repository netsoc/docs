# MetalLB

!!! warning
    We use Kubernetes in IPVS mode as public traffic does not seem to route using the default iptables mode.

[MetalLB](https://metallb.org/) implements `LoadBalancer` services for non-cloud hosted Kubernetes.

The deployment of MetalLB itself is fairly straightforward; a chosen node will answer ARP requests for a specific IP
received on the TCD WAN interface. It's important to be aware of some of the caveats and issues with MetalLB, however.
Firstly, some somewhat advanced routing is required on nodes since there are effectively 2 default gateways: one for
outbound traffic from the machine itself and another for responding to traffic on public IPs.
[This post](https://itnext.io/configuring-routing-for-metallb-in-l2-mode-7ea26e19219e)
explains how to set this up. The exact config is detailed in the
[provisioning documentation](../../../../infrastructure/provisioning/node/#network-setup).

The main one to note is the `Cluster` vs `Local` `externalTrafficPolicy` option (this is applied to the `Service`
objects). [As explained in MetalLB's documentation](https://metallb.org/usage/#layer2), the default `Cluster` policy
distributes traffic across all pods selected by the `Service` but overwrites the original source IP address. `Local`
solves this issue but will only push traffic to pods that are on the same node as is "announcing" the IP. It's also
worth remembering [the rules for sharing IPs between multiple services](https://metallb.org/usage/#ip-address-sharing).

Finally, there is unfortunately a bug in `kube-proxy` that currently means traffic originating from inside the cluster
to IPs advertised with MetalLB will not route correctly. A deployment of
[network-node-manager](https://github.com/kakao/network-node-manager) works around this problem.
