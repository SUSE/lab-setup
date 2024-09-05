# Let's Encrypt Helm Chart

This Helm chart will install certificate issuers using [Let's Encrpyt](https://letsencrypt.org/).

This chart must be installed after `cert-manager`, which is a requirement for the issuers to work and be used.

## Quick start

Install the app with minimal settings:

```bash
# adds the repo
helm repo add devpro https://devpro.github.io/helm-charts
helm repo update

# installs the chart (this examples assumes NGINX Ingress Controller is installed)
helm upgrade --install letsencrypt devpro/letsencrypt \
  --namespace cert-manager \
  --set registration.emailAddress=someuser@domain.com \
  --set ingress.className=nginx

# checks installation is ok
kubectl get ClusterIssuers -n cert-manager
```

Clean-up:

```bash
helm delete letsencrypt -n cert-manager
```

## Troubleshooting

### Check existing resources

```bash
kubectl get Issuers,ClusterIssuers,Certificates,CertificateRequests,Orders,Challenges --all-namespaces
```
