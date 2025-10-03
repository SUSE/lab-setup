#!/bin/bash

#######################################
# Create a service token for SUSE Observability
# Output:
#   The service token
# Arguments:
#   url (SUSE Observability)
#   service_token (SUSE Observability)
#   cluster_name
#   role
# Examples:
#   observability_create_service_token https://obs.suse.com/ xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx lab-dsu37834 stackstate-k8s-troubleshooter
#######################################
observability_create_service_token() {
  local url=$1
  local service_token=$2
  local cluster_name=$3
  local role=$4

  local resp
  resp=$(/usr/local/bin/sts service-token create --name $cluster_name --roles $role -o json --url $url --service-token $service_token)

  echo $resp | jq -r '."service-token".token'
}

#######################################
# Delete a service token for SUSE Observability
# Arguments:
#   url (SUSE Observability)
#   service_token (SUSE Observability)
#   cluster_name
# Examples:
#   observability_delete_service_token https://obs.suse.com/ xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx lab-dsu37834
#######################################
observability_delete_service_token() {
    local url=$1
    local service_token=$2
    local cluster_name=$3

    local tokens token_id

    tokens=$(/usr/local/bin/sts service-token list -o json --url $url --service-token $service_token)
    token_id=$(echo $tokens | jq -r '."service-tokens"[] | select(.name == "'$cluster_name'") | .id')
    if [ -n "$token_id" ]; then
        /usr/local/bin/sts service-token delete --id $token_id --url $url --service-token $service_token
        echo ">>> Service token named '${cluster_name}' deleted"
    else
        echo ">>> Service token named '${cluster_name}' not found"
    fi
}
