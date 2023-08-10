# Module 4 - Observe traffic flows in Calico Cloud

## Install sample application stacks

1. From the cloned directory, execute:

    ```bash
    kubectl apply -f manifests
    ```
  
    (Optional) Also install the metrics-server on EKS to get an idea as to the resource consumption on the cluster

    ```bash
    kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
    ```

    Connect to Calico Cloud GUI. From the menu select `Service Graph > Default`. Explore the options.
  
## Check traffic flows

1. Try sending some traffic between the pods

   a. From the ```management-ui``` pod in ```management-ui``` namespace to the ```customer``` pod in the ```yaobank``` namespace  

    ```bash
    kubectl exec -it -n management-ui deploy/management-ui -- sh -c 'curl -m3 -sI http://customer.yaobank 2>/dev/null | grep -i http'
    ```

   The expected result should be ```HTTP/1.0 200 OK``` indicating that the request succeeded between the namespaces

   b. From the service graph and the application, we can also see that there is traffic correctly flowing within each microservice   application pods.

2. Each application also has a webserver with a ```LoadBalancer``` service to access from the internet to check that the application is functioning normally.

   a. Validate and access the ```management-ui``` svc of the Stars application via the ```Loadbalancer``` service in a browser

    ```bash
    kubectl get svc -n management-ui
    ```

      The output gives the external-IP of the AWS LB that can be used to access the svc

    ```bash
    NAME            TYPE           CLUSTER-IP       EXTERNAL-IP                                                                  PORT(S)        AGE
    management-ui   LoadBalancer   10.100.154.186   a2b94c3b1192d490f8c4b1b9caf30589-1684915063.ca-central-1.elb.amazonaws.com   80:31996/TCP   4h48m
    ```

    In a browser, the following should be seen:

   b. Validate and access the  ```customer``` svc of the Yaobank application via its ```Loadbalancer``` service in a browser

    ```bash
    kubectl get svc customer -n yaobank
    ```

      The output gives the external-IP of the AWS LB that can be used to access the svc

    ```bash
    NAME       TYPE           CLUSTER-IP      EXTERNAL-IP                                                                  PORT(S)        AGE
    customer   LoadBalancer   10.100.75.183   a373657b6b99a44e58503a2377ec7de9-1936085547.ca-central-1.elb.amazonaws.com   80:30180/TCP   3h14m
    ```

    In a browser, the following should be seen:


[:arrow_right: Module 5 - Secure pod traffic using Calico Policy Recommender](module-5-secure-pod-traffic.md)   <br>

[:arrow_left: Module 3 - Deploy an EKS cluster](module-3-connect-calicocloud.md)

[:leftwards_arrow_with_hook: Back to Main](../README.md)  
