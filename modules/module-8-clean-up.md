# Module 8 - Clean up

1. Delete the example application stacks.

   ```bash
   kubectl delete -f manifests/01-stars.yaml
   kubectl delete -f pre/02-yaobank.yaml
   kubectl delete ns hipstershop
   ```

2. Delete EKS cluster.

   ```bash
   source ~/labVars.env
   eksctl delete cluster --name $CLUSTERNAME --region $REGION
   ```

3. Delete Cloud9 instance.

   Navigate to `AWS Console` > `Services` > `Cloud9` and remove your workspace environment, e.g. `tigera-workspace`.

4. Delete IAM role created for this workshop.

   Use your local shell to run the follow AWS CLI commands:

   ```bash
   IAM_ROLE='tigera-workshop-admin'
   ADMIN_POLICY_ARN=$(aws iam list-policies --query 'Policies[?PolicyName==`AdministratorAccess`].Arn' --output text)
   aws iam detach-role-policy --role-name $IAM_ROLE --policy-arn $ADMIN_POLICY_ARN
   aws iam remove-role-from-instance-profile --instance-profile-name $IAM_ROLE --role-name $IAM_ROLE
   aws iam delete-instance-profile --instance-profile-name $IAM_ROLE
   aws iam delete-role --role-name $IAM_ROLE
   ```

   If this command fails, you can remove the role via AWS Console once you delete the Cloud9 instance

---

[:leftwards_arrow_with_hook: Back to Main](../README.md)  <br>

[:arrow_left: Module 7 - Use Observability to Troubleshoot Connectivity Issues](module-7-troubleshooting.md)
