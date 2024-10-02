# Portworx BBQ Helm Chart

This chart will install the **Portworx BBQ (pxbbq)** demo application in a Kubernetes cluster ([source](https://github.com/theITHollow/shanksbbq)).

You can learn more about it by looking at [Azure/kubernetes-hackfest](https://github.com/Azure/kubernetes-hackfest/blob/master/labs/storage/portworx/README.md) repository.

## Quick start

Install the app with default settings:

```bash
# adds the repo
helm repo add suse-lab-setup https://opensource.suse.com/lab-setup
helm repo update

# installs the chart
helm upgrade --install portworx-bbq suse-lab-setup/portworx-bbq --namespace pxbbq --create-namespace
```

Look at [values.yaml](values.yaml) for the configuration.

Clean-up:

```bash
helm delete portworx-bbq --namespace pxbbq
kubectl delete ns pxbbq
```

## Chart dependencies

### MongoDB chart

Add Helm repo:

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
```

Search for the latest package:

```bash
helm search repo -l mongodb --versions
```

Update `Chart.yaml`.

Update `Chart.lock`:

```bash
helm dependency update
```
