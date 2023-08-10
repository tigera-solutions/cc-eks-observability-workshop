# Module 5 - Secure pod traffic using Calico Policy Recommender

In this module, we will focus on securing the pod traffic of the Stars application using the Calico Policy Recommender as a baseline and understanding how to visualize and troubleshoot any unintended behaviour. An important consideration here is that the policy recommender cannot work properly if a global deny policy is already applied as it needs to be able to look at the accepted flows to determine the behaviour in a certain time range.

As the Stars application is comprised of microservices in three namespaces, we will use the policy recommender to create namespace-scoped policies for each namespace one by one and then tweak policies as needed.

## Policy Recommender Steps

1. Select the correct cluster context on the top right, then in the left hamburger menu click on ```Policies > Recommend a Policy``` on the top right

    ![policy_rec_menu](https://github.com/tigera-solutions/cc-eks-observability-workshop/assets/117195889/32db94b0-20d8-4eb9-8ea0-426321c260ca)

2. Select the ```client``` namespace, click ```Advanced Options``` and uncheck the ```User only protected flows``` option, then click ```Recommend``` on the top right

   ![rec_policy](https://github.com/tigera-solutions/cc-eks-observability-workshop/assets/117195889/9e6a16a7-fa86-4f01-8755-340385243e9c)

4. Select the ```Stage``` button after evaluating the current rules, this puts the policy in a preview-only mode and doesn't enforce the policy.

   ![stage_policy](https://github.com/tigera-solutions/cc-eks-observability-workshop/assets/117195889/445213a2-d7ec-48ef-b5c2-a12ef32f24c3)
    
5. Repeat the steps for the ```management-ui``` and the ```stars``` namespaces as well.

6. The policy board should show the staged policies and already we see there is some traffic being denied that may possibly be legitimate. We investigate this further in the next section. 
   
    ![staged_policies_default](https://github.com/tigera-solutions/cc-eks-observability-workshop/assets/117195889/c62ea68a-390f-4385-915c-46c5cc0e00fb)


## Visualize denied staged traffic via Elasticsearch Log Explorer

1. To explore the flows that would be denied by the staged policies, we can explore the logs better in the ElasticSearch instance that collects all the flow logs. This can be accessed by clicking on ```Logs``` in the left menu, this takes us to the Kibana dashboard in a new browser tab.
    
    ![Logs_menu](https://github.com/tigera-solutions/cc-eks-observability-workshop/assets/117195889/8c20ddf6-f0bc-4325-a81d-71af8370d69e)

2. From the hamburger menu on the top left corner, click ```Discover```.

   ![kibana_discover](https://github.com/tigera-solutions/cc-eks-observability-workshop/assets/117195889/85a5702b-e210-4c4f-a784-ec5a66d7f63c) 

4. From the left menu bar just below Add filter, ensure tigera_secure_ee_flows* index is selected and then click on the plus sign next to the following flow logs metadata to filter through the metadata. Make sure to filter as per the order listed below to have an organized and clear view of the filtered information. Change the filter time range to ```last 15 minutes```.

    ```bash
    source_namespace
    source_name_aggr
    dest_namespace
    dest_name_aggr
    dest_port
    reporter
    policies
    ```
    ![add_field](https://github.com/tigera-solutions/cc-eks-observability-workshop/assets/117195889/7c5e974e-e10b-42f9-8809-fbe43540adf2)

5. Once the above filter is implemented, you should see a page similar to the following:
    ![filtered_logs](https://github.com/tigera-solutions/cc-eks-observability-workshop/assets/117195889/c49e7ff9-1b31-4326-b161-2620ad4e7d41)

6. Type the following in the search bar of the ```Discover``` page, this will look for any traffic that would be getting denied by the staged policies we implemented:

    ```policies:{ all_policies: *default.staged**deny*  }```

    We see some matches on traffic that our staged policies would be denying. Let's try to understand what flows are being blocked, whether they are legitimate traffic that instead needs to be allowed, and make the required changes to the policy.

## Making edits to the staged policies back in the policy recommender

1. We see that there are denied flows in two of the policies that are legitimate flows that need to be allowed.

   a. Firstly, we see that there is traffic being denied to the ```management-ui``` from the public internet (our browser trying to send traffic to the LB service). The reason for this is that the ingress ```Allow``` rule currently in place is allowing cluster-wide inbound traffic as per the ```global()``` selector but we need it to be wider than that to allow TCP traffic from 0.0.0.0/0 to the application. Let's make that change.

   Click on the ```management-ui``` policy and click ```Edit Policy``` on the top-right to go into edit mode
    ![edit_mgmt_ui](https://github.com/tigera-solutions/cc-eks-observability-workshop/assets/117195889/fc3993f8-c56a-45cd-939f-14387c1e956c)

   Click on the edit icon to ```Edit Rule``` for the ingress policy rule
    ![edit_rule_icon](https://github.com/tigera-solutions/cc-eks-observability-workshop/assets/117195889/cc46a984-ace4-4ac7-a7b1-16e0521e45f4)

   X to remove and recreate the rule for all TCP traffic

   b. Secondly, we are seeing that within the stars namespace-scoped policy, the frontend and backend pods aren't able to communicate with each other, and we can see that while egress is allowed within the stars namespace between these pods but there needs to be an ingress rule as well to be allowed. Let's go ahead and make that change.
    
    Before:
    ![unfull_stars](https://github.com/tigera-solutions/cc-eks-observability-workshop/assets/117195889/6a940102-5964-4887-a3ec-a49513b053ae)

    After:
    ![full_stars](https://github.com/tigera-solutions/cc-eks-observability-workshop/assets/117195889/69ad8519-5b73-4411-9eb6-9bc7dde24852)

3. Checking back in the ElasticSearch log explorer, we see that we eventually hit no more matches for staged denied flows, which is what we want because no match means there is no undesired traffic hitting this rule. In production environments, make sure to do your due diligence that there is no denied traffic before enforcing your deny rules. Now we can go ahead and implement/Enforce our policy and all legitimate traffic should still flow.

    ![zero_results_good](https://github.com/tigera-solutions/cc-eks-observability-workshop/assets/117195889/859f5ba0-d045-457d-bda7-74f4b5290da9)

## Testing traffic flow to ```yaobank``` namespace

Let's re-run the traffic test from the ```management-ui``` pod in ```management-ui``` namespace to the ```customer``` pod in the ```yaobank``` namespace

```bash
    kubectl exec -it -n management-ui deploy/management-ui -- sh -c 'curl -m3 -sI http://customer.yaobank 2>/dev/null | grep -i http'
```

We should get ```command terminated with exit code 1``` as a result.

Since we have configured the namespace-scoped policies for the Stars app to only allow the traffic we want, the implicit deny has blocked traffic to ```yaobank``` thus giving us the microsegmentation we need, and we were able to utilize the observability features of Calico Cloud to ensure that our legitimate traffic is still allowed.

The service graph should show no denied flows and accessing the application through the browser should still work fine after implementing the policy.

Finally, download the policies as YAMLs so that it can be used in the next module.

[:arrow_right: Module 6 - Zero-trust security for pod traffic](module-6-zero-trust-security.md)   <br>

[:arrow_left: Module 4 - Observe traffic flows in Calico Cloud](module-4-observe-traffic.md)

[:leftwards_arrow_with_hook: Back to Main](../README.md) 
