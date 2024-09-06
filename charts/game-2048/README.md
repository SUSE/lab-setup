# Game 2048 Helm Chart

This chart will install the "2048 game" web application in a Kubernetes cluster.

## Quick start

Install the app with default settings:

```bash
# adds the repo
helm repo add suse-lab-setup https://opensource.suse.com/lab-setup
helm repo update

# installs the chart
helm upgrade --install game-2048 suse-lab-setup/game-2048 --namespace demo --create-namespace
```

Look at [values.yaml](values.yaml) for the configuration.

Clean-up:

```bash
helm delete game-2048
kubectl delete ns demo
```
