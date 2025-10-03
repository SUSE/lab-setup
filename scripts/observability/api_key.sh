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

  local resp
  /usr/local/bin/sts rbac create-subject --subject $cluster_name-agent --service-token $service_token --url $url
  /usr/local/bin/sts rbac grant --subject $cluster_name-agent --permission update-metrics --service-token $service_token --url $url
  resp=$(/usr/local/bin/sts service-token create --name $cluster_name --roles $cluster_name-agent --service-token $service_token --url $url -o json)

  echo $resp | jq -r '."service-token".token'
}
