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
  if [ $? -ne 0 ]; then
    echo "Failed to install cert-manager CRDs"
    exit 1
  fi
  helm upgrade --install cert-manager jetstack/cert-manager \
    --namespace cert-manager --create-namespace \
    --version ${version}
  if [ $? -ne 0 ]; then
    echo "Failed to install cert-manager"
    exit 1
  fi
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
  kubectl apply -f - <<EOF
---
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-staging
spec:
  acme:
    server: https://acme-staging-v02.api.letsencrypt.org/directory
    email: ${emailAddress}
    privateKeySecretRef:
      name: letsencrypt-staging
    solvers:
      - http01:
          ingress:
            class: ${ingressClassname}
---
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: ${emailAddress}
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
      - http01:
          ingress:
            class: ${ingressClassname}
EOF
  if [ $? -ne 0 ]; then
    echo "Failed to create Let's Encrypt cluster issuer"
    exit 1
  fi
  sleep 5
  while kubectl get clusterissuers -o json | jq -e '.items[] | select(.status.conditions[] | select(.type == "Ready" and .status != "True"))' > /dev/null; do
    sleep 1
  done
}
