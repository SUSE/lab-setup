#!/bin/bash

#######################################
# DS389 - restrict permissions:
#   - prevent normal users from reading the whole directory
# Global vars:
#   _ldap_uri
#   _ldap_basedn
#   _admin_user
#   _admin_pwd
# Examples:
#   ds389_restrict_permissions
#######################################
function ds389_restrict_permissions() {
  ldapmodify -D "${_admin_user}" -w "${_admin_pwd}" -x  -H "${_ldap_uri}" << EOL
dn: ou=people,${_ldap_basedn}
changetype: modify
delete: aci
aci: (targetattr="objectClass || description || nsUniqueId || uid || displayName || loginShell || uidNumber || gidNumber || gecos || homeDirectory || cn || memberOf || mail || nsSshPublicKey || nsAccountLock || userCertificate")(targetfilter="(objectClass=posixaccount)")(version 3.0; acl "Enable anyone user read"; allow (read, search, compare)(userdn="ldap:///anyone");)
 
dn: ou=people,${_ldap_basedn}
changetype: modify
add: aci
aci: (targetattr="objectClass || description || nsUniqueId || uid || displayName || loginShell || uidNumber || gidNumber || gecos || homeDirectory || cn || memberOf || mail || nsSshPublicKey || nsAccountLock || userCertificate")(targetfilter="(objectClass=posixaccount)")(version 3.0; acl "Enable self user read"; allow (read, search, compare)(userdn="ldap:///self");)
EOL
}

#######################################
# DS389 - Grant user privileges to read the whole directory
# Global vars:
#   _ldap_uri
#   _ldap_basedn
#   _admin_user
#   _admin_pwd
# Arguments:
#   1 - Username (Default: ldap_user)
# Examples:
#   ds389_user_private_read [<a_user>]
#######################################
function ds389_ldap_user-user_private_read() {
  ldapmodify -D "${_admin_user}" -w "${_admin_pwd}" -x  -H "${_ldap_uri}" << EOL
dn: cn=user_private_read,ou=permissions,${_ldap_basedn}
changetype: modify
add: member
member: uid=${1:-ldap_user},ou=people,${_ldap_basedn}
EOL
}

#######################################
# DS389 - Verify user has access
# Global vars:
#   _ldap_uri
#   _ldap_basedn
# Arguments:
#   1 - ldap user DN
#   2 - ldap user pwd
# Examples:
#   ds389_ldap_user_access_check "uid=ldap_user,ou=people,dc=mydemo,dc=lab" "mypassword"
#######################################
function ds389_ldap_user_access_check() {
  ldapsearch -x  -D "${1}" -w "${2}" -H "${_ldap_uri}"  -b "${_ldap_basedn}"
}

#######################################
# DS389 - Install 389 Directory server
# Global vars:
#   _ldap_uri
#   _ldap_basedn
#   _admin_user
#   _admin_pwd
# Examples:
#   ds389_install
#######################################
function ds389_install() {
  # add the repo
  helm repo add suse-lab-setup https://opensource.suse.com/lab-setup
  helm repo update
  # installs the chart with default parameters
  if [[ -f values.yaml ]]
  then
    helm upgrade --install ds389 suse-lab-setup/ds389 -f values.yaml
  else
    helm upgrade --install ds389 suse-lab-setup/ds389
  fi
  sleep 60
  ds389_restrict_permissions
  ds389_ldap_user-user_private_read
}

#######################################
# DS389 - Uninstall 389 Directory server
# Arguments:
#   1 - Namespace (Default: ds389)
#   2 - App_name (Default: ds389)
# Examples:
#   ds389_uninstall [<ds389> <ds389>]
#######################################
function ds389_uninstall() {
  kubectl -n ${1:-ds389} delete ServiceAccount/${2:-ds389}-sa Secret/dirsrv-tls-secret Secret/dirsrv-dm-password StatefulSet/${2:-ds389} Ingress/${2:-ds389} Service/${2:-ds389} service/${2:-ds389}-internal-svc  service/${2:-ds389}-external-svc Namespace/${1:-ds389}
  sleep 15 
}
