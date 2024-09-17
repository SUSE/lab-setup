#!/bin/bash

#######################################
# Get the state of a component in SUSE Observability
# Arguments:
#   url (SUSE Observability)
#   service_token (SUSE Observability)
#   stql
# Returns:
#   "CRITICAL", "DEVIATING", "UNKNOWN" or "CLEAR"
# Examples:
#   observability_get_component_state https://obs.suse.com/ xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx "lobel = \"cluster-name:$DOWNSTREAM_CLUSTER_NAME\" AND ..."
#######################################
observability_get_component_state() {
    local url=$1
    local service_token=$2
    local stql=$3

    local component=$(observability_get_component_snapshot $url $service_token "$stql")
    return $(echo $component | jq -r '.viewSnapshotResponse.components[0].state.healthState')
}

#######################################
# Query the snapshot of a component in SUSE Observability
# Arguments:
#   url (SUSE Observability)
#   service_token (SUSE Observability)
#   stql
# Returns:
#   JSON viewSnapshotResponse
# Examples:
#   observability_get_component_snapshot https://obs.suse.com/ xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx "lobel = \"cluster-name:$DOWNSTREAM_CLUSTER_NAME\" AND ..."
#######################################
observability_get_component_snapshot() {
    local url=$1
    local service_token=$2
    local stql=$3

    local req=$(cat <<EOF
{
  "query":        "$stql",
  "queryVersion": "1.0",
  "metadata":     {
    "groupingEnabled":       false,
    "showIndirectRelations": false,
    "minGroupSize":          10,
    "groupedByLayer":        false,
    "groupedByDomain":       false,
    "groupedByRelation":     false,
    "autoGrouping":          false,
    "connectedComponents":   false,
    "neighboringComponents": false,
    "showFullComponent":     false
  }
}
EOF
)
    curl -s -k -H "Authorization: ApiKey $service_token" -H "Content-Type: application/json" -X POST -d "$req" $url/api/snapshot
}
