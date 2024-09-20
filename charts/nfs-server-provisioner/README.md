# NFS server provisioner

This Helm chart will install [NFS Server Provisioner](https://github.com/kubernetes-sigs/nfs-ganesha-server-and-external-provisioner) in a Kubernetes cluster.

## Quick start

Install the application with the default settings:

```bash
# adds the repo
helm repo add suse-lab-setup https://opensource.suse.com/lab-setup
helm repo update

# installs the chart
helm upgrade --install nfs-server-provisioner suse-lab-setup/nfs-server-provisioner --namespace nfs-provisioner --create-namespace
```

Look at [values.yaml](values.yaml) for the configuration.

Clean-up:

```bash
helm delete nfs-server-provisioner
kubectl delete ns nfs-provisioner
```

## Upstream version update

- Look for the available versions:

```bash
# adds bitnami helm chart repository
helm repo add nfs-ganesha-server-and-external-provisioner https://kubernetes-sigs.github.io/nfs-ganesha-server-and-external-provisioner/
helm repo update

# lists available charts
helm search repo nfs-server-provisioner
```

- Update [Chart.yaml](Chart.yaml)

- Update Chart.lock file:

```bash
helm dependency update
```
