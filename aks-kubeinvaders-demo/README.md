This folder contains resources for the demo of chaos engineering experiments with KubeInvaders tool.

In the ```terraform``` folder you can find infrastructure provisioning templates that will set up a simple AKS cluster that you can install applications to straight away.

In the ```app-deploy-templates``` folder you can find Kubernetes YAML templates to deploy demo app, Nyan Cat, and KubeInvaders (values file for deploying it with Helm chart is provided) to the provisioned AKS cluster.

```deploy-demo.sh``` contains detailed instructions and commands that you would need to set it all up.