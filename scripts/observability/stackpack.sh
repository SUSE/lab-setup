#!/bin/bash


observability_delete_stackpack() {
  url=$1
  service_token=$2
  cluster_name=$3

  stackpacks=$(/usr/local/bin/sts stackpack list-instances --name kubernetes-v2 -o json --url $url --service-token $service_token)
  stackpack_id=$(echo $stackpacks | jq -r '.instances[] | select(.config.kubernetes_cluster_name == "'$cluster_name'") | .id')
  if [ ! -z "$stackpack_id" ];  then
    /usr/local/bin/sts stackpack uninstall --id $stackpack_id --url $url --service-token $service_token --name kubernetes-v2
  else
    echo ">>> StackPack for cluster '${cluster_name}' not found"
    return
  fi
}

# Check if the StackPack for the cluster is installed
# Returns 0 if the StackPack is installed, 1 otherwise
observability_check_stackpack() {
  url=$1
  service_token=$2
  cluster_name=$3

  stackpacks=$(/usr/local/bin/sts stackpack list-instances --name kubernetes-v2 -o json --url $url --service-token $service_token)
  stackpack_id=$(echo $stackpacks | jq -r '.instances[] | select(.config.kubernetes_cluster_name == "'$cluster_name'") | .id')
  if [ ! -z "$stackpack_id" ];  then
    return 0
  else
    return 1
  fi
}
