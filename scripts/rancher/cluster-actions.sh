#!/bin/sh
# Collection of functions to manage clusters from Rancher

#######################################
# List clusters managed by Rancher
# Arguments:
#   Rancher URL
#   token
# Examples:
#   rancher_list_clusters rancher.random_string.geek xxxxx
#######################################
rancher_list_clusters() {
  local rancherUrl=$1
  local token=$2

  echo "Listing clusters registered in Rancher..."
  curl -s -k "$rancherUrl/v3/clusters" -H "Authorization: Bearer $token" | jq .
}

#######################################
# Create downstream custom cluster in Rancher
# Globals:
#   CLUSTER_ID
# Arguments:
#   Rancher URL
#   token
#   name
#   version (Kubernetes)
# Examples:
#   rancher_create_customcluster rancher.random_string.geek xxxxx demo 'v1.27.16+rke2r1'
#######################################
rancher_create_customcluster() {
  local rancherUrl=$1
  local token=$2
  local name=$3
  local version=$4

  echo "Creating downstream cluster in Rancher..."
  CLUSTER_CONFIG=$(cat <<EOF
{
  "type": "provisioning.cattle.io.cluster",
  "metadata": {
    "namespace": "fleet-default",
    "name": "$name"
  },
  "spec": {
    "rkeConfig": {
      "chartValues": {
        "rke2-calico": {}
      },
      "upgradeStrategy": {
        "controlPlaneConcurrency": "1",
        "controlPlaneDrainOptions": {
          "deleteEmptyDirData": true,
          "disableEviction": false,
          "enabled": false,
          "force": false,
          "gracePeriod": -1,
          "ignoreDaemonSets": true,
          "skipWaitForDeleteTimeoutSeconds": 0,
          "timeout": 120
        },
        "workerConcurrency": "1",
        "workerDrainOptions": {
          "deleteEmptyDirData": true,
          "disableEviction": false,
          "enabled": false,
          "force": false,
          "gracePeriod": -1,
          "ignoreDaemonSets": true,
          "skipWaitForDeleteTimeoutSeconds": 0,
          "timeout": 120
        }
      },
      "machineGlobalConfig": {
        "cni": "calico",
        "disable-kube-proxy": false,
        "etcd-expose-metrics": false
      },
      "machineSelectorConfig": [
        {
          "config": {
            "protect-kernel-defaults": false
          }
        }
      ],
      "etcd": {
        "disableSnapshots": false,
        "s3": null,
        "snapshotRetention": 5,
        "snapshotScheduleCron": "0 */5 * * *"
      },
      "registries": {
        "configs": {},
        "mirrors": {}
      },
      "machinePools": []
    },
    "machineSelectorConfig": [
      {
        "config": {}
      }
    ],
    "kubernetesVersion": "$version",
    "defaultPodSecurityAdmissionConfigurationTemplateName": "",
    "localClusterAuthEndpoint": {
      "enabled": false,
      "caCerts": "",
      "fqdn": ""
    }
  }
}
EOF
  )

  CLUSTER_CREATION_RESPONSE=$(curl -s -k -H "Authorization: Bearer $token" \
    -H 'Content-Type: application/json' \
    -X POST \
    -d "$CLUSTER_CONFIG" \
    "$rancherUrl/v1/provisioning.cattle.io.clusters")
  echo "DEBUG CLUSTER_CREATION_RESPONSE=${CLUSTER_CREATION_RESPONSE}"
  sleep 10

  rancher_get_clusterid $rancherUrl $token $name
  echo "DEBUG CLUSTER_ID=${CLUSTER_ID}"
}

#######################################
# Get cluster ID from its name
# Globals:
#   CLUSTER_ID
# Arguments:
#   Rancher URL
#   token
#   name
# Examples:
#   rancher_get_clusterid rancher.random_string.geek xxxxx demo
#######################################
rancher_get_clusterid() {
  local rancherUrl=$1
  local token=$2
  local name=$3

  CLUSTER_ID=$(curl -s ${rancherUrl}/v3/clusters?name=${name} \
    -H 'content-type: application/json' \
    -H "Authorization: Bearer ${token}" \
    | jq -r .data[0].id)
}

#######################################
# Get cluster registration command line from Rancher
# Globals:
#   REGISTRATION_COMMAND
# Arguments:
#   Rancher URL
#   token
#   cluster ID
# Examples:
#   rancher_get_clusterregistrationcommand rancher.random_string.geek xxxxx 42
#######################################
rancher_get_clusterregistrationcommand() {
  local rancherUrl=$1
  local token=$2
  local id=$3

  CLUSTER_REGISTRATION_RESPONSE=$(curl -s -k -H "Authorization: Bearer $token" "${rancherUrl}/v3/clusters/$id/clusterRegistrationTokens")
  echo "DEBUG CLUSTER_REGISTRATION_RESPONSE=${CLUSTER_REGISTRATION_RESPONSE}"

  REGISTRATION_COMMAND=$(echo $CLUSTER_REGISTRATION_RESPONSE | jq -r '.data[0].nodeCommand')
  echo "DEBUG REGISTRATION_COMMAND=${REGISTRATION_COMMAND}"
}
