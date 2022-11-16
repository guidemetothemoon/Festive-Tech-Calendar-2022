# List of commands required to build demo environment

# Login to Azure CLI

az login --use-device-code

# Confirm correct subscription context

az account show

# Set correct Azure Subscription

az account set --subscription "<SUBSCRIPTION_ID>"

# Check deployment with Terraform Plan and output plan file for later use

terraform plan -out ./plans/festivetech.tfplan

# Apply configuration

terraform apply ./plans/festivetech.tfplan

# Install Chaos Mesh for use with Azure Chaos Studio

helm repo add chaos-mesh https://charts.chaos-mesh.org
helm repo update
kubectl create ns chaos-testing
helm install chaos-mesh chaos-mesh/chaos-mesh --namespace=chaos-testing --set chaosDaemon.runtime=containerd --set chaosDaemon.socketPath=/run/containerd/containerd.sock

# POST DEMO ONLY - Destroy Demo Environment

terraform destroy

#TODO 
# Add second AKS Cluster in Secondary Region
# Add Ingress Controller installation/configuration (Optional) @Kristina - Do we need this or shall we just expose services as we need?
# Add Traffic Manager with confiuration to point to Clusters
# Add Helm/kubectl apply for workloads to deploy.