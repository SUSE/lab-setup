#!/bin/bash
# Collection of functions to manage clusters from Rancher

#######################################
# List clusters managed by Rancher
#######################################
rancher_list_clusters() {
  echo "Listing clusters registered in Rancher..."
  kubectl get clusters.provisioning.cattle.io --all-namespaces | awk 'NR>1 {print $2}'
}

#######################################
# Create downstream custom cluster in Rancher
# Globals:
#   CLUSTER_ID
# Arguments:
#   name
#   version (Kubernetes)
# Examples:
#   rancher_create_customcluster demo 'v1.27.16+rke2r1'
#######################################
rancher_create_customcluster() {
  local name=$1
  local version=$2

  echo "Creating downstream cluster in Rancher..."
  cat <<EOF | kubectl apply -f -
apiVersion: provisioning.cattle.io/v1
kind: Cluster
metadata:
  name: "$name"
  namespace: fleet-default
spec:
  kubernetesVersion: "$version"
  localClusterAuthEndpoint: {}
  rkeConfig:
    chartValues:
      rke2-calico: {}
    dataDirectories: {}
    etcd:
      snapshotRetention: 5
      snapshotScheduleCron: 0 */5 * * *
    machineGlobalConfig:
      cni: calico
      disable-kube-proxy: false
      etcd-expose-metrics: false
    machinePoolDefaults: {}
    machineSelectorConfig:
      - config:
          protect-kernel-defaults: false
    registries: {}
    upgradeStrategy:
      controlPlaneConcurrency: '1'
      controlPlaneDrainOptions:
        deleteEmptyDirData: true
        disableEviction: false
        enabled: false
        force: false
        gracePeriod: -1
        ignoreDaemonSets: true
        ignoreErrors: false
        postDrainHooks: null
        preDrainHooks: null
        skipWaitForDeleteTimeoutSeconds: 0
        timeout: 120
      workerConcurrency: '1'
      workerDrainOptions:
        deleteEmptyDirData: true
        disableEviction: false
        enabled: false
        force: false
        gracePeriod: -1
        ignoreDaemonSets: true
        ignoreErrors: false
        postDrainHooks: null
        preDrainHooks: null
        skipWaitForDeleteTimeoutSeconds: 0
        timeout: 120
EOF
  
  sleep 10

  rancher_get_clusterid $name
  echo "DEBUG CLUSTER_ID=${CLUSTER_ID}"
}

#######################################
# Get cluster ID from its name
# Globals:
#   CLUSTER_ID
# Arguments:
#   name
# Examples:
#   rancher_get_clusterid demo
#######################################
rancher_get_clusterid() {
  local name=$1

  CLUSTER_ID=$(kubectl get cluster.provisioning.cattle.io -n fleet-default -o=jsonpath="{range .items[?(@.metadata.name==\"${name}\")]}{.status.clusterName}{end}")
}

#######################################
# Get cluster registration command line from Rancher
# Globals:
#   REGISTRATION_COMMAND
# Arguments:
#   cluster ID
# Examples:
#   rancher_get_clusterregistrationcommand 42
#######################################
rancher_get_clusterregistrationcommand() {
  local id=$1

  REGISTRATION_COMMAND=$(kubectl get clusterregistrationtoken.management.cattle.io -n $id -o=jsonpath='{.items[*].status.nodeCommand}'
)
  echo "DEBUG REGISTRATION_COMMAND=${REGISTRATION_COMMAND}"
}
