# Module 5 - Secure pod traffic using Calico Policy Recommender

In this module, we will focus on securing the pod traffic of the Stars application using the Calico Policy Recommender as a baseline and understanding how to visualize and troubleshoot any unintended behaviour. An important consideration here is that the policy recommender cannot work properly if a global deny policy is already applied as it needs to be able to look at the accepted flows to determine the behaviour in a certain time range.

As the Stars application is comprised of microservices in three namespaces, we will use the policy recommender to create namespace-scoped policies for each namespace one by one and then tweak policies as needed.

## Policy Recommendations Steps

1. Select the correct cluster context on the top right, then in the left hamburger menu click on ```Policies > Recommendations```

   ![policy_gui_1](https://github.com/tigera-solutions/cc-eks-blueprint-secpos-workshop/assets/117195889/3980f84a-0128-4e28-b023-f79450658e56)

2. You will be presented with a page to enable the feature. Click the ```Enable Policy Recommendations``` button to instantiate the daemonset/pods for the feature.

    ![enable_policy_reco](https://github.com/tigera-solutions/cc-eks-blueprint-secpos-workshop/assets/117195889/720a7cd9-bc9b-4733-9b4d-7599d9d6c188)

   You can check that ```policy-recommendation``` shows ```True``` under the ```AVAILABLE``` column when you run ```kubectl get tigerastatus```

   ```bash
   NAME                            AVAILABLE   PROGRESSING   DEGRADED   SINCE
    apiserver                       True        False         False      123m
    calico                          True        False         False      125m
    cloud-core                      True        False         False      125m
    compliance                      True        False         False      123m
    image-assurance                 True        False         False      123m
    intrusion-detection             True        False         False      123m
    log-collector                   True        False         False      123m
    management-cluster-connection   True        False         False      123m
    monitor                         True        False         False      124m
    policy-recommendation           True        False         False      123m
    ```

3. In the Calico Cloud GUI, click on ```Global Settings``` on the top right and make the ```Stabilization Period``` and ```Processing Interval``` a bit more aggressive to have the policy recommendations show up more quickly.

    ![glob_Settings_location](https://github.com/tigera-solutions/cc-eks-blueprint-secpos-workshop/assets/117195889/f9b4a7be-0869-48cc-9337-052a3693270a)

    ![glob_Setting_short](https://github.com/tigera-solutions/cc-eks-blueprint-secpos-workshop/assets/117195889/a74a774a-4128-44cb-a4a0-65bc56adbdb3)

4. Once the traffic is analyzed and the policies show up in the ```Recommendations``` section, select the policies we are interested in for the ```Stars``` application across its namespaces and select the ```Bulk Actions``` option and ```Add to policy board``` .

    ![select_policy_reco](https://github.com/tigera-solutions/cc-eks-blueprint-secpos-workshop/assets/117195889/5da08c08-bd8b-4a23-b6d5-28e8bf41d97c)

    ![add_to_board](https://github.com/tigera-solutions/cc-eks-blueprint-secpos-workshop/assets/117195889/1176fb99-f8b2-4746-b676-071f731768fe)

5. Navigating to the policy board should show the staged policies are in their own tier called ```namespace-isolation``` and we are ready review them by clicking on them. Staged policies are a preview mode where you can see the impact of the policy before you decide to enforce it.

![show_board](https://github.com/tigera-solutions/cc-eks-blueprint-secpos-workshop/assets/117195889/02ec1c1d-3101-4e19-8318-b5b2ed79889a)

## Visualize denied staged traffic via Elasticsearch Log Explorer

1. To explore the flows that would be denied by the staged policies, we can explore the logs better in the ElasticSearch instance that collects all the flow logs. This can be accessed by clicking on ```Logs``` in the left menu, this takes us to the Kibana dashboard in a new browser tab.

    ![Logs_menu](https://github.com/tigera-solutions/cc-eks-observability-workshop/assets/117195889/8c20ddf6-f0bc-4325-a81d-71af8370d69e)

2. From the hamburger menu on the top left corner, click ```Discover```.

   ![kibana_discover](https://github.com/tigera-solutions/cc-eks-observability-workshop/assets/117195889/85a5702b-e210-4c4f-a784-ec5a66d7f63c)

3. From the left menu bar just below Add filter, ensure tigera_secure_ee_flows* index is selected and then click on the plus sign next to the following flow logs metadata to filter through the metadata. Make sure to filter as per the order listed below to have an organized and clear view of the filtered information. Change the filter time range to ```last 15 minutes```.

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

4. Once the above filter is implemented, you should see a page similar to the following:
    ![filtered_logs](https://github.com/tigera-solutions/cc-eks-observability-workshop/assets/117195889/c49e7ff9-1b31-4326-b161-2620ad4e7d41)

5. Type the following in the search bar of the ```Discover``` page, this will look for any traffic that would be getting denied by the staged policies we implemented:

    ```policies:{ all_policies: *default.staged**deny*  }```

    If we see any matches on traffic that our staged policies would be denying, let's try to understand what flows are being blocked, whether they are legitimate traffic that instead needs to be allowed, and make the required changes to the policy.

## Testing traffic flow to ```yaobank``` namespace

Let's re-run the traffic test from the ```management-ui``` pod in ```management-ui``` namespace to the ```customer``` pod in the ```yaobank``` namespace

```bash
kubectl exec -it -n management-ui deploy/management-ui -- sh -c 'curl -m3 -sI http://customer.yaobank 2>/dev/null | grep -i http'
```

We should get ```command terminated with exit code 1``` as a result.

Since we have configured the namespace-scoped policies for the Stars app to only allow the traffic we want, the implicit deny has blocked traffic to ```yaobank``` thus giving us the microsegmentation we need, and we were able to utilize the observability features of Calico Cloud to ensure that our legitimate traffic is still allowed.

The service graph should show no denied flows and accessing the application through the browser should still work fine after implementing the policy.

Finally, download the policies as YAMLs so that it can be used in the next module.

[:arrow_right: Module 6 - Zero-trust security for pod traffic](module-6-zero-trust-security.md)  

[:arrow_left: Module 4 - Observe traffic flows in Calico Cloud](module-4-observe-traffic.md)

[:leftwards_arrow_with_hook: Back to Main](../README.md)
