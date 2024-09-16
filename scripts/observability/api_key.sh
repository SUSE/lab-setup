#!/bin/bash

observability_create_ingestion_api_key() {
  url=$1
  service_token=$2
  cluster_name=$3

  resp=$(/usr/local/bin/sts ingestion-api-key create --name $cluster_name -o json --url $url --service-token $service_token)
  return $(echo $resp | jq -r '."ingestion-api-key".apiKey')
}

observability_delete_ingestion_api_key() {
  url=$1
  service_token=$2
  cluster_name=$3

  keys=$(/usr/local/bin/sts ingestion-api-key list -o json --url $url --service-token $service_token)
  key_id=$(echo $keys | jq -r '."ingestion-api-keys"[] | select(.name == "'$cluster_name'") | .id')
  if [ ! -z "$key_id" ]; then
    /usr/local/bin/sts ingestion-api-key delete --id $key_id --url $url --service-token $service_token
  else
    echo ">>> Ingestion API key for cluster '${cluster_name}' not found"
    return
  fi
}
