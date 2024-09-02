#!/bin/bash

# downloads and sources shared scripts
SETUP_FOLDER=temp
curl -sfL https://raw.githubusercontent.com/SUSE/lab-setup/feature/init-solution/scripts/download.sh \
  | GIT_REVISION=refs/heads/feature/init-solution sh -s -- -o $SETUP_FOLDER
. $SETUP_FOLDER/scripts/index.sh

# defines variables
K3S_VERSION='v1.23'
CERTMANAGER_VERSION='v1.11.0'
LETSENCRYPT_EMAIL_ADDRESS='john.wick@google.com'
RANCHER_REPOSITORY='latest'
RANCHER_VERSION='2.8.2'
RANCHER_DOMAIN="rancher.management1.${_SANDBOX_ID}.instruqt.io"
RANCHER_REPLICAS='1'
ADMIN_PASSWORD='Sus3R@ncherR0x'
INGRESS_CLASSNAME='traefik'
DOWNSTREAM_CLUSTER_NAME='demo'
RKE2_K8S_VERSION='v1.27.16+rke2r1'

# generic flow
create_k3s_cluster $K3S_VERSION
copy_k3s_kubeconfig
wait_for_cluster_availability
install_certmanager $CERTMANAGER_VERSION
create_clusterissuers_letsencrypt $INGRESS_CLASSNAME $LETSENCRYPT_EMAIL_ADDRESS
install_rancher_certmanagerclusterissuer $RANCHER_REPOSITORY $RANCHER_VERSION $RANCHER_REPLICAS $RANCHER_DOMAIN letsencrypt-prod
RANCHER_URL="https://${RANCHER_DOMAIN}"
do_rancher_first_login $RANCHER_URL $ADMIN_PASSWORD
# TODO
