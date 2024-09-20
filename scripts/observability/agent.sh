#!/bin/bash

#######################################
# Install the Observability agent in the cluster
# Arguments:
#   url (SUSE Observability)
#   cluster_name
#   ingestion_api_key
# Examples:
#   observability_agent_install https://obs.suse.com/ demo xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
#######################################
observability_agent_install() {
    local url=$1
    local cluster_name=$1
    local ingestion_api_key=$2
    echo "Installing Observability agent..."
    helm repo add suse-observability https://charts.rancher.com/server-charts/prime/suse-observability
    helm repo update

    helm upgrade --install suse-observability-agent suse-observability/suse-observability-agent \
        --namespace suse-observability --create-namespace \
        --set stackstate.apiKey=${ingestion_api_key} \
        --set stackstate.url="${url}/receiver/stsAgent" \
        --set stackstate.cluster.name=${cluster_name}

    kubectl wait pods -n suse-observability -l app.kubernetes.io/instance=suse-observability-agent --for condition=Ready 2>/dev/null
}
