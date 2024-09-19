# Scripting

## Bash functions

Name                                           | Source
-----------------------------------------------|-----------------------------------------------------------------------------
`k3s_copy_kubeconfig`                          | [k3s/cluster-lifecycle.sh](k3s/cluster-lifecycle.sh)
`k3s_create_cluster`                           | [k3s/cluster-lifecycle.sh](k3s/cluster-lifecycle.sh)
`k8s_create_letsencryptclusterissuer`          | [kubernetes/certificate-management.sh](kubernetes/certificate-management.sh)
`k8s_install_certmanager`                      | [kubernetes/certificate-management.sh](kubernetes/certificate-management.sh)
`k8s_wait_fornodesandpods`                     | [kubernetes/cluster-status.sh](kubernetes/cluster-status.sh)
`keycloak_login`                               | [authentication/keycloak.sh](authentication/keycloak.sh)
`keycloak_create_user`                         | [authentication/keycloak.sh](authentication/keycloak.sh)
`keycloak_delete_user`                         | [authentication/keycloak.sh](authentication/keycloak.sh)
`observability_check_stackpack`                | [observability/stackpack.sh](observability/stackpack.sh)
`observability_create_ingestion_api_key`       | [observability/api-key.sh](observability/api-key.sh)
`observability_delete_ingestion_api_key`       | [observability/api-key.sh](observability/api-key.sh)
`observability_delete_stackpack`               | [observability/stackpack.sh](observability/stackpack.sh)
`observability_get_component_snapshot`         | [observability/stql.sh](observability/stql.sh)
`observability_get_component_state`            | [observability/stql.sh](observability/stql.sh)
`observability_install_cli`                    | [observability/cli.sh](observability/cli.sh)
`rancher_create_apikey`                        | [rancher/user-actions.sh](rancher/user-actions.sh)
`rancher_create_customcluster`                 | [rancher/cluster-actions.sh](rancher/cluster-actions.sh)
`rancher_first_login`                          | [rancher/manager-lifecycle.sh](rancher/manager-lifecycle.sh)
`rancher_get_clusterid`                        | [rancher/cluster-actions.sh](rancher/cluster-actions.sh)
`rancher_get_clusterregistrationcommand`       | [rancher/cluster-actions.sh](rancher/cluster-actions.sh)
`rancher_install_withcertmanagerclusterissuer` | [rancher/manager-lifecycle.sh](rancher/manager-lifecycle.sh)
`rancher_list_clusters`                        | [rancher/cluster-actions.sh](rancher/cluster-actions.sh)
`rancher_login_withpassword`                   | [rancher/user-actions.sh](rancher/user-actions.sh)
`rancher_update_password`                      | [rancher/user-actions.sh](rancher/user-actions.sh)
`rancher_update_serverurl`                     | [rancher/manager-settings.sh](rancher/manager-settings.sh)
`rancher_wait_capiready`                       | [rancher/manager-lifecycle.sh](rancher/manager-lifecycle.sh)

## Concrete examples

- [Rancher installation with downstream cluster](../samples/scripting/rancher_installation.sh)
