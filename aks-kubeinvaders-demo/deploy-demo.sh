# Based upon this link from Microsoft - it has all the information you need to set up Terraform with Azure: https://learn.microsoft.com/en-us/azure/developer/terraform/create-k8s-cluster-with-tf-and-aks

# 1. Create service principal to be able to provision infrastructure in Azure from Terraform
az ad sp create-for-rbac --name <service_principal_name> --role Contributor --scopes /subscriptions/<azure_subscription_id>

# 2. Replace placeholders in terraform.tfvars with recently created service principal appid and password

# 3. Create an AKS cluster with Terraform
# A basic AKS cluster will be created with 1 Linux node, Log Analytics and HTTP Application Routing add-on

terraform init
terraform plan -out main.tfplan
terraform apply main.tfplan


# 4. Install applications on Anewly created KS cluster - demo app (NYAN CAT) and KubeInvaders for chaos experiments

# 4.1.0 Get DNS Zone that was created by HTTP Application Routing add-on for AKS cluster
az aks addon show --addon http_application_routing --name aks-kubeinvaders --resource-group aks-kubeinvaders-rg | grep HTTPApplicationRoutingZoneName

# 4.1.1 Replace [AKS_DNS_ZONE] placeholder in app-deploy-templates/chaos-nyan-cat-ingress.yaml and app-deploy-templates/kubeinvaders-values.yaml with value retrieved from 4.1.0

# 4.1.2 Deploy applications to AKS
cd app-deployment-templates
helm repo add kubeinvaders https://lucky-sideburn.github.io/helm-charts/

kubectl create namespace kubeinvaders && kubectl create namespace chaos-nyan-cat
helm upgrade --install kubeinvaders --set-string target_namespace="chaos-nyan-cat" -n kubeinvaders kubeinvaders/kubeinvaders -f kubeinvaders-values.yaml --set image.tag=v1.9 --version 1.9
kubectl apply -f chaos-nyan-cat-deploy.yaml -f chaos-nyan-cat-ingress.yaml -n chaos-nyan-cat

# 5. Clean up all resources (including service principal)

terraform plan -destroy -out main.destroy.tfplan
terraform apply main.destroy.tfplan

az ad sp show --id <service_principal_app_id>
az ad sp list --display-name "<service_principal_display_name>" --query "[].{\"Object ID\":id}" --output table
az ad sp delete --id <service_principal_object_id>