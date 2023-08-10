# Module 6 - Zero-trust security for pod traffic

Tiers are a hierarchical construct used to group policies and enforce higher precedence policies that other teams cannot circumvent, providing the basis for **Identity-aware microsegmentation**.

All Calico and Kubernetes security policies reside in tiers. You can start “thinking in tiers” by grouping your teams and the types of policies within each group.

In our scenario, we have a lot of namescoped application-specific policies for traffic which are fine-grained controls. Some of the policies can be segmented into higher tiers for wider cluster-wide policy implementation by a security team while the application team still has access to their own tier.

In our scenario we will consider the Star application to be used by one tenant while the Yaobank application is being used by another. We want to restrict the traffic within tenants as a cluster-wide policy in a higher ```security``` tier.

## Security tier policies overview

The ```security``` tier will be used to implement high-level guardrails for the cluster.

- A ```threatfeed``` security policy will be enforced for all cluster workloads. The policy will deny egress connectivity to malicious IPs in the ```threatfeed```.
- The ```cluster-dns-allow-all``` security policy will have rules to permit ingress DNS traffic to the ```kube-dns``` endpoints on TCP and UDP port 53 from all endpoints in the cluster. The security policy will also have egress rules to permit all endpoints in the cluster to send DNS traffic to the ```kube-dns``` endpoints on the same ports.
- Finally, ```security-default-pass``` policy will be used to pass any traffic that is not explicitly allowed or denied in this tier to the subsequent tier for policy processing.

## App tier policies overview

The ```app``` tier is used by the Star and Yaobank applications to deploy namespace-scoped policies.

- Yaobank application policies consist of coarse-grained security policies for Yaobank app per namespace. An allow policy for the namespace will ensure that all workloads inside the namespace can communicate with one another. However, security ```rules``` must permit traffic flows in and out of the namespace.
- Stars application policies are the fine-grained policies that were developed using the policy recommender in the previous module.
- Finally, the ```app-default-pass``` security policy has the lowest precedence in the app tier. It is deployed to ensure that a pass action is applied to all endpoints traffic matched in this tier, but the traffic was not explicitly allowed or denied. This rule causes the traffic matching it to be further processed in the default tier. We will implement global ```default-deny``` policy in the default tier blocking any traffic that was not explicitly allowed in the previous tiers.

## Default tier policies overview

The default tier is used to implement global default deny policy.

- ```default-deny``` denies any traffic that is not explicitly allowed in security, platform, and app tiers.

## Building the policies

1. Apply the tiers YAML
  
    ```bash
    kubectl apply -f manifests/00-tiers.yaml
    ```

2. Apply the ```default-deny``` policy as a ```Staged``` policy first in the ```default``` tier for all the necessary namespaces:

    ```bash
    kubectl apply -f manifests/01-default-deny.yaml
    ```

3. Apply the ```security``` tier policies

    ```bash
    kubectl apply -f manifests/02-security.yaml
    ```

4. Apply the ```app``` tier policies

   ```bash
   kubectl apply -f manifests/03-app.yaml
   ```

5. Finally enforce the default deny policy from the Calico Cloud GUI.

6. Examine the results in the service graph and run traffic tests to verify.  

[:arrow_right: Module 7 - Use Observability to Troubleshoot Connectivity Issues](module-7-troubleshooting.md)   <br>

[:arrow_left: Module 5 - Observe traffic flows in Calico Cloud](module-5-secure-pod-traffic.md)

[:leftwards_arrow_with_hook: Back to Main](../README.md) 