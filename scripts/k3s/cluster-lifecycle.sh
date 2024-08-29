# Creates a K3s cluster
# ---------------------
# Arguments:
#   - K3s version
# Examples
#   - create_k3s_cluster "v1.23"
create_k3s_cluster() {
  local version=$1

  echo "Create management cluster (K3s)..."
  curl -sfL https://get.k3s.io | INSTALL_K3S_CHANNEL="${version}" K3S_KUBECONFIG_MODE="644" sh -
}

# Copy K3s kubeconfig file to local user file
copy_k3s_kubeconfig() {
  mkdir -p ~/.kube
  cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
  chmod 600 ~/.kube/config
}
