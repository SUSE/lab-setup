#!/bin/bash

# downloads and sources shared scripts
SETUP_FOLDER=temp
curl -sfL https://raw.githubusercontent.com/SUSE/lab-setup/feature/init-solution/scripts/setup.sh \
  | GIT_REVISION=refs/heads/feature/init-solution sh -s -- -o $SETUP_FOLDER
. $SETUP_FOLDER/scripts/index.sh

# defines variables
K3S_VERSION="v1.23"
CERTMANAGER_VERSION="v1.11.0"
LETSENCRYPT_EMAIL_ADDRESS=john.wick@google.com
RANCHER_VERSION="2.8.2"
RANCHER_DOMAIN="rancher.management1.${_SANDBOX_ID}.instruqt.io"
RANCHER_URL="https://${RANCHER_DOMAIN}"
RANCHER_API_URL="${RANCHER_URL}/v3"
ADMIN_USERNAME="admin"
ADMIN_PASSWORD="Sus3R@ncherR0x"
DOWNSTREAM_CLUSTER_NAME="demo"
RKE2_K8S_VERSION="v1.27.16+rke2r1"
INGRESS_CLASSNAME="traefik"

create_k3s_cluster $K3S_VERSION
wait_for_cluster_availability
copy_k3s_kubeconfig
install_certmanager $CERTMANAGER_VERSION
create_clusterissuers_letsencrypt $INGRESS_CLASSNAME $LETSENCRYPT_EMAIL_ADDRESS
install_rancher_externalclusterissuer latest $RANCHER_VERSION 1 rancher.${HOSTNAME}.${_SANDBOX_ID}.instruqt.io letsencrypt-prod

# TODO
