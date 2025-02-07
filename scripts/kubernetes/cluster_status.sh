#!/bin/bash
# Collection of functions to add query status on a Kubernetes cluster

#######################################
# Wait for the Kubernetes cluster to be available (checking nodes and pods)
# Arguments:
#   None
# Examples:
#   k8s_wait_fornodesandpods
#######################################
k8s_wait_fornodesandpods() {
  # checks nodes are ready
  while ! kubectl get nodes --no-headers 2>/dev/null | grep -q .; do
    echo 'Waiting for nodes to be available...'
    sleep 5
  done
  while true; do
    NOT_READY_NODES=$(kubectl get nodes --no-headers 2>/dev/null | grep -v " Ready" | wc -l)
    if [ "$NOT_READY_NODES" -eq 0 ]; then
      echo 'All nodes are ready.'
      break
    else
      sleep 5
    fi
  done

  # checks pods are completed or running
  while ! kubectl get pods --all-namespaces --no-headers 2>/dev/null | grep -q .; do
    echo 'Waiting for pods to be available...'
    sleep 5
  done
  while true; do
    NOT_READY_PODS=$(kubectl get pods --all-namespaces --field-selector=status.phase!=Running,status.phase!=Succeeded --no-headers 2>/dev/null | wc -l)
    if [ "$NOT_READY_PODS" -eq 0 ]; then
      echo 'All pods are in Running or Completed status.'
      break
    else
      # print pods not in Running or Completed status
      kubectl get pods --all-namespaces --field-selector=status.phase!=Running,status.phase!=Succeeded --no-headers
      echo "Sleeping..."
      sleep 10
    fi
  done
}
