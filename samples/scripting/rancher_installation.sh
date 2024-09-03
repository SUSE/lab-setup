#!/bin/bash

# downloads and sources shared scripts
SETUP_FOLDER=temp
curl -sfL https://raw.githubusercontent.com/SUSE/lab-setup/feature/init-solution/scripts/download.sh \
  | GIT_REVISION=refs/heads/feature/init-solution sh -s -- -o $SETUP_FOLDER
. $SETUP_FOLDER/scripts/index.sh

# defines variables
K3S_VERSION='v1.23'
CERTMANAGER_VERSION='v1.11.0'
LETSENCRYPT_EMAIL_ADDRESS='john.wick@thecontinental.hotel'
RANCHER_REPOSITORY='latest'
RANCHER_VERSION='2.8.2'
RANCHER_DOMAIN="rancher.awesome.com"
RANCHER_REPLICAS='1'
ADMIN_PASSWORD='Sus3R@ncherR0x'
INGRESS_CLASSNAME='traefik'
DOWNSTREAM_CLUSTER_NAME='demo'
RKE2_K8S_VERSION='v1.27.16+rke2r1'

# create management cluster
k3s_create_cluster $K3S_VERSION
k3s_copy_kubeconfig
k8s_wait_fornodesandpods
kubectl get nodes
kubectl get pods -A
k8s_install_certmanager $CERTMANAGER_VERSION
k8s_create_letsencryptclusterissuer $INGRESS_CLASSNAME $LETSENCRYPT_EMAIL_ADDRESS
kubectl get clusterissuers

# install and initialize Rancher
rancher_install_withcertmanagerclusterissuer $RANCHER_REPOSITORY $RANCHER_VERSION $RANCHER_REPLICAS $RANCHER_DOMAIN letsencrypt-prod
RANCHER_URL="https://${RANCHER_DOMAIN}"
rancher_first_login $RANCHER_URL $ADMIN_PASSWORD
rancher_create_apikey $RANCHER_URL $LOGIN_TOKEN 'Automation API Key'
echo "DEBUG API_TOKEN=${API_TOKEN}"
rancher_list_clusters $RANCHER_URL $API_TOKEN
rancher_wait_capiready

# creates downstream cluster
rancher_create_customcluster $RANCHER_URL $API_TOKEN $DOWNSTREAM_CLUSTER_NAME $RKE2_K8S_VERSION
rancher_get_clusterregistrationcommand $RANCHER_URL $API_TOKEN $CLUSTER_ID

# executes the registration from downstream server
echo 'Registering downstream cluster (RKE2)...'
ssh -o StrictHostKeyChecking=accept-new downstream1 "${REGISTRATION_COMMAND} --etcd --controlplane --worker"
