# Cow Demo Helm Chart

This chart will install the "Cow Demo" web application in a Kubernetes cluster.

## Quick start

Install the app with default settings:

```bash
# adds the repo
helm repo add devpro https://devpro.github.io/helm-charts
helm repo update

# installs the chart
helm upgrade --install cow-demo devpro/cow-demo --namespace demo --create-namespace
```

Look at [values.yaml](values.yaml) for the configuration.

Clean-up:

```bash
helm delete cow-demo
kubectl delete ns demo
```
