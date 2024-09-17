#!/bin/bash

#######################################
# Delete a StackPack instance from SUSE Observability
# Arguments:
#   url (SUSE Observability)
#   service_token (SUSE Observability)
#   cluster_name
# Examples:
#   observability_delete_stackpack https://obs.suse.com/ xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx demo
#######################################
observability_delete_stackpack() {
  local url=$1
  local service_token=$2
  local cluster_name=$3

  local stackpacks=$(/usr/local/bin/sts stackpack list-instances --name kubernetes-v2 -o json --url $url --service-token $service_token)
  local stackpack_id=$(echo $stackpacks | jq -r '.instances[] | select(.config.kubernetes_cluster_name == "'$cluster_name'") | .id')
  if [ ! -z "$stackpack_id" ];  then
    /usr/local/bin/sts stackpack uninstall --id $stackpack_id --url $url --service-token $service_token --name kubernetes-v2
    echo ">>> StackPack for cluster '${cluster_name}' deleted"
  else
    echo ">>> StackPack for cluster '${cluster_name}' not found"
    return
  fi
}

#######################################
# Check if a StackPack instance exists in SUSE Observability
# Arguments:
#   url (SUSE Observability)
#   service_token (SUSE Observability)
#   cluster_name
# Returns:
#   0 if the StackPack instance exists, 1 otherwise
# Examples:
#   observability_check_stackpack https://obs.suse.com/ xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx demo
#######################################
observability_check_stackpack() {
  local url=$1
  local service_token=$2
  local cluster_name=$3

  local stackpacks=$(/usr/local/bin/sts stackpack list-instances --name kubernetes-v2 -o json --url $url --service-token $service_token)
  local stackpack_id=$(echo $stackpacks | jq -r '.instances[] | select(.config.kubernetes_cluster_name == "'$cluster_name'") | .id')
  if [ ! -z "$stackpack_id" ];  then
    return 0
  else
    return 1
  fi
}
