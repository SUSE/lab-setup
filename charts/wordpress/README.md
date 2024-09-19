# WordPress Helm Chart

This Helm chart will install [WordPress](https://wordpress.com/) in a Kubernetes cluster.

## Quick start

Install the app with default settings:

```bash
# adds the repo
helm repo add suse-lab-setup https://opensource.suse.com/lab-setup
helm repo update

# installs the chart
helm upgrade --install wordpress suse-lab-setup/wordpress --namespace demo --create-namespace
```

Look at [values.yaml](values.yaml) for the configuration.

Clean-up:

```bash
helm delete wordpress
kubectl delete ns demo
```

## Configuration examples

### Ingress (NGINX class with self-signed certificate) + WordPress password as secret + Azure storage class

```yaml
secrets:
  wordpressPassword:
    encryptedValue: xxx
wordpress:
  global:
    storageClass: azureblob-fuse
  wordpressUsername: myuser
  wordpressBlogName: "My WordPress!"
  existingSecret: wordpress-credentials
  ingress:
    enabled: true
    ingressClassName: nginx
    hostname: wordpress.demo
    tls: true
    selfSigned: true
  mariadb:
    auth:
      rootPassword: "xxx"
      password: "xxx"
```

## Troubleshooting

### MariaDB failing to start

Check storage class compatibility

### Empty website & incomplete template

View pod logs

Increase livenessProbe initialDelaySeconds as WordPress installation may take several minutes (see [Issue #9563](https://github.com/bitnami/charts/issues/9563))

### Error 503

Make sure Kubernetes `wordpress` service exists (may also be linked to long installation time and disabled probes)

## Upstream version update

- Look for the available versions:

```bash
# adds bitnami helm chart repository
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# lists available charts
helm search repo wordpress
```

- Update [Chart.yaml](Chart.yaml)

- Update Chart.lock file:

```bash
helm dependency update
```
