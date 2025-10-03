# Scripting

## Bash functions

### Instruqt

Name                        | Source
----------------------------|-------------------------------------
`instruqt_wait_hoststartup` | [instruqt/host.sh](instruqt/host.sh)

### K3s

Name                  | Source
----------------------|-----------------------------------------------------
`k3s_copy_kubeconfig` | [k3s/cluster_lifecycle.sh](k3s/cluster_lifecycle.sh)
`k3s_create_cluster`  | [k3s/cluster_lifecycle.sh](k3s/cluster_lifecycle.sh)

### Kubernetes

Name                                  | Source
--------------------------------------|-----------------------------------------------------------------------------
`k8s_create_letsencryptclusterissuer` | [kubernetes/certificate_management.sh](kubernetes/certificate_management.sh)
`k8s_install_certmanager`             | [kubernetes/certificate_management.sh](kubernetes/certificate_management.sh)
`k8s_wait_fornodesandpods`            | [kubernetes/cluster_status.sh](kubernetes/cluster_status.sh)

### Keycloak

Name                   | Source
-----------------------|---------------------------------------------------------
`keycloak_login`       | [authentication/keycloak.sh](authentication/keycloak.sh)
`keycloak_create_user` | [authentication/keycloak.sh](authentication/keycloak.sh)
`keycloak_delete_user` | [authentication/keycloak.sh](authentication/keycloak.sh)

### Linux

Name                         | Source
-----------------------------|-------------------------------
`linux_create_fileAndLoopDevice` | [linux/disk.sh](linux/disk.sh)

### Rancher

Name                                           | Source
-----------------------------------------------|-------------------------------------------------------------
`rancher_create_apikey`                        | [rancher/user_actions.sh](rancher/user_actions.sh)
`rancher_create_customcluster`                 | [rancher/cluster_actions.sh](rancher/cluster_actions.sh)
`rancher_first_login`                          | [rancher/manager_lifecycle.sh](rancher/manager_lifecycle.sh)
`rancher_get_clusterid`                        | [rancher/cluster_actions.sh](rancher/cluster_actions.sh)
`rancher_get_clusterregistrationcommand`       | [rancher/cluster_actions.sh](rancher/cluster_actions.sh)
`rancher_install_withcertmanagerclusterissuer` | [rancher/manager_lifecycle.sh](rancher/manager_lifecycle.sh)
`rancher_list_clusters`                        | [rancher/cluster_actions.sh](rancher/cluster_actions.sh)
`rancher_login_withpassword`                   | [rancher/user_actions.sh](rancher/user_actions.sh)
`rancher_update_password`                      | [rancher/user_actions.sh](rancher/user_actions.sh)
`rancher_update_serverurl`                     | [rancher/manager_settings.sh](rancher/manager_settings.sh)
`rancher_wait_capiready`                       | [rancher/manager_lifecycle.sh](rancher/manager_lifecycle.sh)

### Rancher Prime

Name                                           | Source
-----------------------------------------------|-------------------------------------------------------------
`rancherprime_install_withcertmanagerclusterissuer` | [rancher/manager_lifecycle.sh](rancher/manager_lifecycle.sh)

### SUSE Observability

Name                                     | Source
-----------------------------------------|---------------------------------------------------------
`observability_check_stackpack`          | [observability/stackpack.sh](observability/stackpack.sh)
`observability_create_ingestion_api_key` | [observability/api_key.sh](observability/api_key.sh)
`observability_delete_ingestion_api_key` | [observability/api_key.sh](observability/api_key.sh)
`observability_delete_stackpack`         | [observability/stackpack.sh](observability/stackpack.sh)
`observability_get_component_snapshot`   | [observability/stql.sh](observability/stql.sh)
`observability_get_component_state`      | [observability/stql.sh](observability/stql.sh)
`observability_install_cli`              | [observability/cli.sh](observability/cli.sh)
`observability_create_service_token`     | [observability/service_token.sh](observability/service_token.sh)
`observability_delete_service_token`     | [observability/service_token.sh](observability/service_token.sh)

### SUSE Linux (previously SLES, SLE Micro)

Name                            | Source
--------------------------------|-------------------------------------------------------
`suselinux_install_git`         | [suselinux/packages.sh](suselinux/packages.sh)
`suselinux_install_helm`        | [suselinux/packages.sh](suselinux/packages.sh)
`suselinux_install_kubectl`     | [suselinux/packages.sh](suselinux/packages.sh)
`suselinux_install_openiscsi`   | [suselinux/packages.sh](suselinux/packages.sh)
`suselinux_install_podman`      | [suselinux/packages.sh](suselinux/packages.sh)
`suselinux_register_cloudguest` | [suselinux/registration.sh](suselinux/registration.sh)

## Concrete examples

- [Rancher installation with downstream cluster](../samples/scripting/rancher_installation.sh)
