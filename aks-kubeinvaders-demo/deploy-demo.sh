cd app-deployment-templates
helm repo add kubeinvaders https://lucky-sideburn.github.io/helm-charts/

kubectl create namespace kubeinvaders chaos-nyan-cat
helm install kubeinvaders --set-string target_namespace="chaos-nyan-cat" -n kubeinvaders kubeinvaders/kubeinvaders -f kubeinvaders-values.yaml --set image.tag=v1.9 --version 1.9
kubectl apply -f chaos-nyan-cat-deploy.yaml -f chaos-nyan-cat-ingress.yaml -n chaos-nyan-cat