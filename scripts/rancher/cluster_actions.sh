#!/bin/bash
# Collection of functions to manage clusters from Rancher

#######################################
# List clusters managed by Rancher
# Examples:
#   rancher_list_clusters
#######################################
rancher_list_clusters() {
  echo 'Listing clusters registered in Rancher...'
  kubectl get clusters.provisioning.cattle.io --all-namespaces -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}'
}


#######################################
# Shows Kubernetes version
# Examples:
#   get_k8s_version
#######################################
get_k8s_version() {
  #  echo 'Retrieving Kubernetes version'
  kubectl version -o yaml | yq .serverVersion.gitVersion
}



#######################################
# Shows Rancher version
# Globals:
#   RANCHER_CLUSTER_URL
# Arguments:
#   rancher_cluster_url - optional if RANCHER_CLUSTER URL is defined
# Examples:
#   get_rancher_version https://rancher.clustername.domain.name/
# Return format:
#   {"Version":"v2.10.2","GitCommit":"a8208b7884a5115d31bfda65de78e3a65798179f","RancherPrime":"true"}
#######################################
get_rancher_version() {
  # echo 'Retrieving Rancher version'
  # Thanks Eduardo Mínguez and Josh Meranda
  # other options:
  #  kubectl get po -n cattle-system -l app=rancher -o jsonpath='{.items[0].spec.containers[0].image}'
  #  R: registry.rancher.com/rancher/rancher:v2.10.1
  #  kubectl exec -it -n cattle-system  $(kubectl get po -n cattle-system -l app=rancher -o name) -- rancher --version
  #  R: rancher version v2.10.1 (daaa287448fe866f141beead10ae93ffc2400469)
  if [[ "$1" != "" ]]
  then
    local _rancher_url=${1}ancherversion
  else
    local _rancher_url=
  fi
  if [[ "${_rancher_url}" != "" ]] && [[ "${_rancher_url}" =~ "https://" ]]; then
    curl -k ${_rancher_url}/rancherversion
  else
    echo "ERROR: Missing or incorrect rancher URL"
    exit 1
  fi
}


#######################################
# Create downstream custom cluster in Rancher (don't wait and retrieve name)
# Globals:
#   CLUSTER_ID
# Arguments:
#   name
#   version (Kubernetes)
# Examples:
#   rancher_create_customcluster_nowait demo 'v1.27.16+rke2r1'
#######################################
rancher_create_customcluster_nowait() {
  local name=$1
  local version=$2

  rancher_wait_capiready

  echo 'Creating downstream cluster in Rancher...'
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

  rancher_create_customcluster_nowait $name $version

  sleep 10

  rancher_get_clusterid $name
}

#######################################
# Return cluster ID from its name
# Arguments:
#   name
# Examples:
#   CLUSTER_ID=$(rancher_get_clusterid demo)
#######################################
rancher_return_clusterid() {
  local name=$1

  kubectl get cluster.provisioning.cattle.io -n fleet-default -o=jsonpath="{range .items[?(@.metadata.name==\"${name}\")]}{.status.clusterName}{end}"
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

  CLUSTER_ID=$(rancher_return_clusterid $name)
  echo "DEBUG CLUSTER_ID=${CLUSTER_ID}"
}

#######################################
# Return cluster registration command line from Rancher
# Arguments:
#   cluster ID
# Examples:
#   CLUSTER_REGISTRATION_COMMAND=$(rancher_get_clusterregistrationcommand 42)
#######################################
rancher_return_clusterregistrationcommand() {
  local id=$1

  kubectl get clusterregistrationtoken.management.cattle.io -n $id -o=jsonpath='{.items[*].status.nodeCommand}'
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

  REGISTRATION_COMMAND=$(rancher_return_clusterregistrationcommand $id)
  echo "DEBUG REGISTRATION_COMMAND=${REGISTRATION_COMMAND}"
}
