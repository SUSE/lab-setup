# Helm Charts

## Catalog

* [Cow Demo](cow-demo/README.md)
* [Game 2048](game-2048/README.md)
* [Let's Encrypt](letsencrypt/README.md)
* [NFS-Ganesha](nfs-ganesha/README.md)
* [NFS Server Provisioner](nfs-server-provisioner/README.md)
* [Rancher Cluster Template](rancher-cluster-templates/README.md)
* [WordPress](wordpress/README.md)

## Developer's guide

From within a chart directory:

```bash
# lints a chart
helm lint

# generates the manifest file from a chart (for review/comparison)
helm template <releasename> . -f values.yaml -f values_mine.yaml --namespace demo > temp.yaml

# installs a chart from local source
helm upgrade --install <releasename> . -f values.yaml \
  # --debug > output.yaml \
  --create-namespace --namespace nfs-ganesha
```
