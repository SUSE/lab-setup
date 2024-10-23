#!/bin/bash
# Collection of functions to manage K3s cluster lifecycle

#######################################
# Create a K3s cluster
# Arguments:
#   K3s version
# Examples:
#   k3s_create_cluster "v1.23"
#######################################
k3s_create_cluster() {
  local version=$1

  echo 'Create management cluster (K3s)...'
  curl -sfL https://get.k3s.io | INSTALL_K3S_CHANNEL="${version}" K3S_KUBECONFIG_MODE="644" sh -
}

#######################################
# Copy K3s kubeconfig file to local user file
# Arguments:
#   None
# Examples:
#   k3s_copy_kubeconfig
#######################################
k3s_copy_kubeconfig() {
  mkdir -p ~/.kube
  cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
  chmod 600 ~/.kube/config
}
