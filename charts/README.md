# Helm Charts

## Catalog

* [Cow Demo](cow-demo/README.md)
* [Game 2048](game-2048/README.md)
* [Let's Encrypt](letsencrypt/README.md)
* [WordPress](wordpress/README.md)

## Developer's guide

```bash
# lints a chart
helm lint .

# creates Kubernetes template file from chart (for review/comparison)
helm template myname . -f values.yaml --namespace demo > temp.yaml
```
