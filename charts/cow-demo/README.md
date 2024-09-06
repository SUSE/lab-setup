# Cow Demo Helm Chart

This chart will install the "Cow Demo" web application in a Kubernetes cluster.

## Quick start

Install the app with default settings:

```bash
# adds the repo
helm repo add suse-lab-setup https://opensource.suse.com/lab-setup
helm repo update

# installs the chart
helm upgrade --install cow-demo suse-lab-setup/cow-demo --namespace demo --create-namespace
```

Look at [values.yaml](values.yaml) for the configuration.

Clean-up:

```bash
helm delete cow-demo
kubectl delete ns demo
```
