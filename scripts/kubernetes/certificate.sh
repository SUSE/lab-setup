#!/bin/bash

# Installs cert-manager
# ---------------------
# Arguments:
#   - Version
# Examples
#   - install_certmanager "v1.11.0"
function install_certmanager() {
  local version=$1

  echo "Installing cert-manager..."
  helm repo add jetstack https://charts.jetstack.io
  helm repo update
  kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/${version}/cert-manager.crds.yaml
  helm upgrade --install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version ${version}
  kubectl wait pods -n cert-manager -l app.kubernetes.io/instance=cert-manager --for condition=Ready
}

# Create cluster issuers using Let's Encrypt
# ------------------------------------------
# Arguments:
#   - Ingress class name (traefik, nginx, etc.)
#   - Administrator email address (to receive notifications for Let's Encrypt)
# Examples
#   - create_clusterissuers_letsencrypt traefik john.wick@google.com
function create_clusterissuers_letsencrypt() {
  local ingressClassname=$1
  local emailAddress=$2

  echo "Creating certificate issuers using Let's Encrypt..."
  helm repo add devpro https://devpro.github.io/helm-charts
  helm repo update
  helm upgrade --install letsencrypt devpro/letsencrypt --namespace cert-manager --set ingress.className=${ingressClassname} --set registration.emailAddress=${emailAddress}
}
