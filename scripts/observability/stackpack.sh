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

  if observability_check_stackpack $url $service_token $cluster_name;  then
    /usr/local/bin/sts stackpack uninstall --id $stackpack_id --url $url --service-token $service_token --name kubernetes-v2
    echo ">>> StackPack for cluster '${cluster_name}' deleted"
  else
    echo ">>> StackPack for cluster '${cluster_name}' not found"
  fi
}

#######################################
# Check if a StackPack instance exists in SUSE Observability
# Arguments:
#   url (SUSE Observability)
#   service_token (SUSE Observability)
#   cluster_name
# Returns:
#   `true` if the StackPack instance exists, `false` otherwise
# Examples:
#   observability_check_stackpack https://obs.suse.com/ xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx demo
#######################################
observability_check_stackpack() {
  local url=$1
  local service_token=$2
  local cluster_name=$3

  local stackpacks stackpack_id
  stackpacks=$(/usr/local/bin/sts stackpack list-instances --name kubernetes-v2 -o json --url $url --service-token $service_token)
  stackpack_id=$(echo $stackpacks | jq -r '.instances[] | select(.config.kubernetes_cluster_name == "'$cluster_name'") | .id')
  [[ -n "$stackpack_id" ]]
  return
}
