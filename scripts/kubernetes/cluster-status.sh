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
