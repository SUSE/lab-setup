#!/bin/bash
# Collection of functions to add components to manage certificates in a Kubernetes cluster

#######################################
# Install cert-manager and wait for the the application to be running
# Arguments:
#   cert-manager version
# Examples:
#   k8s_install_certmanager "v1.11.0"
#######################################
k8s_install_certmanager() {
  local version=$1

  echo 'Installing cert-manager...'
  helm repo add jetstack https://charts.jetstack.io
  helm repo update
  kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/${version}/cert-manager.crds.yaml
  helm upgrade --install cert-manager jetstack/cert-manager \
    --namespace cert-manager --create-namespace \
    --version ${version}
  kubectl wait pods -n cert-manager -l app.kubernetes.io/instance=cert-manager --for condition=Ready 2>/dev/null
}

#######################################
# Create certificate cluster issuers using Let's Encrypt
# Arguments:
#   Ingress class name (traefik, nginx, etc.)
#   administrator email address (to receive notifications for Let's Encrypt)
# Examples:
#   k8s_create_letsencryptclusterissuer traefik john.wick@thecontinental.hotel
#######################################
k8s_create_letsencryptclusterissuer() {
  local ingressClassname=$1
  local emailAddress=$2

  echo "Creating certificate issuers using Let's Encrypt..."
  helm repo add suse-lab-setup https://opensource.suse.com/lab-setup
  helm repo update
  helm upgrade --install letsencrypt suse-lab-setup/letsencrypt \
    --namespace cert-manager \
    --set ingress.className=${ingressClassname} \
    --set registration.emailAddress=${emailAddress}
  sleep 5
  while kubectl get clusterissuers -o json | jq -e '.items[] | select(.status.conditions[] | select(.type == "Ready" and .status != "True"))' > /dev/null; do
    sleep 1
  done
}
