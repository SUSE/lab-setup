#!/bin/bash

# Creates a K3s cluster
# ---------------------
# Arguments:
#   - K3s version
# Examples
#   - create_k3s_cluster "v1.23"
function create_k3s_cluster() {
  local version=$1
  echo "Create management cluster (K3s)..."
  curl -sfL https://get.k3s.io | INSTALL_K3S_CHANNEL="${version}" K3S_KUBECONFIG_MODE="644" sh -
}

# Wait for the K3s cluster to be available
function wait_for_cluster_availability() {
  # checks nodes are ready
  while true; do
    NOT_READY_NODES=$(kubectl get nodes --no-headers 2>/dev/null | grep -v " Ready" | wc -l)
    if [ "$NOT_READY_NODES" -eq 0 ]; then
      echo "All nodes are ready."
      break
    else
      echo "Waiting for all nodes to be ready..."
      sleep 5
    fi
  done

  # checks pods are completed or running
  while true; do
    NOT_READY_PODS=$(kubectl get pods --all-namespaces --field-selector=status.phase!=Running,status.phase!=Succeeded --no-headers 2>/dev/null | wc -l)
    if [ "$NOT_READY_PODS" -eq 0 ]; then
      echo "All pods are in Running or Completed status."
      break
    else
      echo "Waiting for all pods to be in Running or Completed status..."
      sleep 5
    fi
  done
}

# Copy K3s kubeconfig file to local user file
function copy_k3s_kubeconfig() {
  mkdir -p ~/.kube
  cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
  chmod 600 ~/.kube/config
}
