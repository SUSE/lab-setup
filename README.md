# Lab Setup

[![CI](https://github.com/SUSE/lab-setup/actions/workflows/ci.yml/badge.svg?branch=develop)](https://github.com/SUSE/lab-setup/actions/workflows/ci.yml)

Welcome! You'll find in this repository some IT material to help setup your lab environments.

It is used internally at SUSE (the goal being to capitalize and factorize), but is open to everyone. Feel free to contribute and share feedback!

## Getting started

### Shell scripting

* Download and source the files (here targetting `develop` branch but you can chose the revision you want):

```bash
SETUP_FOLDER=lab-setup
curl -sfL https://raw.githubusercontent.com/SUSE/lab-setup/feature/init-solution/scripts/download.sh \
  | GIT_REVISION=refs/heads/develop sh -s -- -o $SETUP_FOLDER
. $SETUP_FOLDER/scripts/index.sh
```

* Call a function:

```bash
# create a Kubernetes cluster (K3s distribution)
k3s_create_cluster v1.23
```

* Look at a concrete sample:

  * [samples/scripting/rancher_installation.sh](samples/scripting/rancher_installation.sh)

* Browse the available functions:

Name                                           | Source
-----------------------------------------------|---------------------------------------------------------------------------------------------
`k3s_create_cluster`                           | [scripts/k3s/cluster-lifecycle.sh](scripts/k3s/cluster-lifecycle.sh)
`k3s_copy_kubeconfig`                          | [scripts/k3s/cluster-lifecycle.sh](scripts/k3s/cluster-lifecycle.sh)
`k8s_install_certmanager`                      | [scripts/kubernetes/certificate-management.sh](scripts/kubernetes/certificate-management.sh)
`k8s_create_letsencryptclusterissuer`          | [scripts/kubernetes/certificate-management.sh](scripts/kubernetes/certificate-management.sh)
`k8s_wait_fornodesandpods`                     | [scripts/kubernetes/cluster-status.sh](scripts/kubernetes/cluster-status.sh)
`rancher_list_clusters`                        | [scripts/rancher/cluster-actions.sh](scripts/rancher/cluster-actions.sh)
`rancher_create_customcluster`                 | [scripts/rancher/cluster-actions.sh](scripts/rancher/cluster-actions.sh)
`rancher_get_clusterid`                        | [scripts/rancher/cluster-actions.sh](scripts/rancher/cluster-actions.sh)
`rancher_get_clusterregistrationcommand`       | [scripts/rancher/cluster-actions.sh](scripts/rancher/cluster-actions.sh)
`rancher_install_withcertmanagerclusterissuer` | [scripts/rancher/manager-lifecycle.sh](scripts/rancher/manager-lifecycle.sh)
`rancher_first_login`                          | [scripts/rancher/manager-lifecycle.sh](scripts/rancher/manager-lifecycle.sh)
`rancher_wait_capiready`                       | [scripts/rancher/manager-lifecycle.sh](scripts/rancher/manager-lifecycle.sh)
`rancher_update_serverurl`                     | [scripts/rancher/manager-settings.sh](scripts/rancher/manager-settings.sh)
`rancher_login_withpassword`                   | [scripts/rancher/user-actions.sh](scripts/rancher/user-actions.sh)
`rancher_update_password`                      | [scripts/rancher/user-actions.sh](scripts/rancher/user-actions.sh)
`rancher_create_apikey`                        | [scripts/rancher/user-actions.sh](scripts/rancher/user-actions.sh)
