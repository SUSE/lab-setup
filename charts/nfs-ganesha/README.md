# NFS-Ganesha Helm Chart

This Helm chart will install [NFS-Ganesha](https://nfs-ganesha.github.io/) on a Kubernetes cluster.

## Quick start

Install the app with minimal settings:

```bash
# adds the repo
helm repo add suse-lab-setup https://opensource.suse.com/lab-setup
helm repo update

# installs the chart with default parameters
helm upgrade --install nfs-ganesha suse-lab-setup/nfs-ganesha --create-namespace --namespace nfs-ganesha
```

Clean-up:

```bash
helm delete nfs-ganesha -n nfs-ganesha
kubectl delete ns nfs-ganesha
```
