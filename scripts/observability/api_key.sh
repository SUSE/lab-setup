#!/bin/bash

#######################################
# Create an Ingestion API key for SUSE Observability
# Output:
#   The ingestion API key
# Arguments:
#   url (SUSE Observability)
#   service_token (SUSE Observability)
#   cluster_name
# Examples:
#   observability_create_ingestion_api_key https://obs.suse.com/ xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx demo
#######################################
observability_create_ingestion_api_key() {
  local url=$1
  local service_token=$2
  local cluster_name=$3

  local resp=$(/usr/local/bin/sts ingestion-api-key create --name $cluster_name -o json --url $url --service-token $service_token)

  echo $resp | jq -r '."ingestion-api-key".apiKey'
}

#######################################
# Delete an Ingestion API key for SUSE Observability
# Arguments:
#   url (SUSE Observability)
#   service_token (SUSE Observability)
#   cluster_name
# Examples:
#   observability_delete_ingestion_api_key https://obs.suse.com/ xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx demo
#######################################
observability_delete_ingestion_api_key() {
  local url=$1
  local service_token=$2
  local cluster_name=$3

  local keys=$(/usr/local/bin/sts ingestion-api-key list -o json --url $url --service-token $service_token)
  local key_id=$(echo $keys | jq -r '."ingestion-api-keys"[] | select(.name == "'$cluster_name'") | .id')
  if [ ! -z "$key_id" ]; then
    /usr/local/bin/sts ingestion-api-key delete --id $key_id --url $url --service-token $service_token
    echo ">>> Ingestion API key for cluster '${cluster_name}' deleted"
  else
    echo ">>> Ingestion API key for cluster '${cluster_name}' not found"
  fi
}
