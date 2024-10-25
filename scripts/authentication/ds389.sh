#!/bin/bash



_admin_user="cn=Directory Manager"
_admin_pwd="admin123"
_uri="ldap://node101.mydemo.lab:30389"
_connection_str="-D \"${_admin_user}\" -w \"${_admin_pwd}\" -x  -H \"${_uri}\""
_basedn="dc=mydemo,dc=lab"
_ldap_user_dn="uid=ldap_user,ou=people,${_basedn}"
_ldap_user_pwd="supersecret123"



# Inspired from https://stackoverflow.com/questions/2914220/bash-templating-how-to-build-configuration-files-from-templates-with-bash#11050943
function process_templates() {
       eval "cat <<EOF
$(cat ${template_file} )
EOF
"
}



## DS389: Restrict permissions
## This will:
## -  prevent normal users from reading the whole directory
function ds389_restrict_permissions() {
  ldapmodify ${_connection_str} << EOL
dn: ou=people,${_basedn}
changetype: modify
delete: aci
aci: (targetattr="objectClass || description || nsUniqueId || uid || displayName || loginShell || uidNumber || gidNumber || gecos || homeDirectory || cn || memberOf || mail || nsSshPublicKey || nsAccountLock || userCertificate")(targetfilter="(objectClass=posixaccount)")(version 3.0; acl "Enable anyone user read"; allow (read, search, compare)(userdn="ldap:///anyone");)
 
dn: ou=people,${_basedn}
changetype: modify
add: aci
aci: (targetattr="objectClass || description || nsUniqueId || uid || displayName || loginShell || uidNumber || gidNumber || gecos || homeDirectory || cn || memberOf || mail || nsSshPublicKey || nsAccountLock || userCertificate")(targetfilter="(objectClass=posixaccount)")(version 3.0; acl "Enable self user read"; allow (read, search, compare)(userdn="ldap:///self");)
EOL


}



## DS389: Grant ldap_user privileges to read the whole directory 
function ds389_ldap_user-user_private_read() {
  ldapmodify  ${_connection_str} << EOL
dn: cn=user_private_read,ou=permissions,${_basedn}
changetype: modify
add: member
member: uid=ldap_user,ou=people,${_basedn}
EOL

}


## DS389: Verify ldap_user has access
function ds389_ldap_user-access() {
  ldapsearch -x  -D "${_ldap_user_dn}" -w "${__ldap_user_pwd}" -H "${_uri}"  -b "${_basedn}"
}



## DS389: Install 389 Directory server
function ds389_install() {
  template_file=${LAB_SETUP_PATH}/cloud-init/template_${_type}
  process_templates >/tmp/389.yml
  kubectl apply -f 389.yml 
  sleep 60
  ds389_restrict_permissions
  ds389_ldap_user-user_private_read
}


## DS389: uninstall 389 Directory server
function ds389_uninstall() {
  kubectl -n ds389  delete ServiceAccount/ds389-sa Secret/dirsrv-tls-secret Secret/dirsrv-dm-password StatefulSet/ds389 Ingress/ds389 Service/ds389 Namespace/ds389 service/ds389-internal-svc  service/ds389-external-svc; sleep 15 
}


function usage() {
        echo "Usage:
$0 [install|uninstall|create-user|delete-user|create-group|delete-group|check-user|check-group|change-passwd] <[user|group]> <password>"

}


_arg="$1"


if [[ ! ${_arg} ]]
then
        echo "ERROR: Missing argument"
        usage
        exit 1
fi

case ${_arg} in
  install)
    ds389_install
    ;;
  uninstall)
    ds389_uninstall
    ;;
  create-user)
    [[ "$2" == "" ]] && ( echo "ERROR: Missing user"; usage ;  exit 1)
    # these are only for rancher, therefore doesn't matter if they have the same UID
    dsidm localhost --basedn "${_basedn}" user create --uid $2 --cn $2 --displayName $2 --uidNumber 1001 --gidNumber 1001 --homeDirectory /home/${2}
    ;;
  delete-user)
    [[ "$2" == "" ]] && ( echo "ERROR: Missing user"; usage ;  exit 1)
    ldapmodify ${_connection_str} << EOL
dn: ou=people,${_basedn}
changetype: modify
delete: uid
uid: $2
EOL
    ;;
  create-group)
    [[ "$2" == "" ]] && ( echo "ERROR: Missing group"; usage ;  exit 1)
    dsidm localhost --basedn "${_basedn}" group create --cn $2 ; 
    ;;
  delete-group)
    [[ "$2" == "" ]] && ( echo "ERROR: Missing group"; usage ;  exit 1)
    ldapmodify ${_connection_str} << EOL
dn: ou=group,${_basedn}
changetype: modify
delete: cn
cn: $2
EOL
    ;;
  check-user)
    [[ "$2" == "" ]] && ( echo "ERROR: Missing user"; usage ;  exit 1)
    dsidm localhost --basedn "${_basedn}" account get-by-dn uid=${2},ou=people,${_basedn}
    ;;
  check-group)
    [[ "$2" == "" ]] && ( echo "ERROR: Missing group"; usage ;  exit 1)
    dsidm localhost --basedn "${_basedn}" account get-by-dn uid=${2},ou=group,${_basedn}
    ;;
  change-passwd)
    [[ "$2" == "" ]] && ( echo "ERROR: Missing user"; usage ;  exit 1)
    [[ "$3" == "" ]] && ( echo "ERROR: Missing password"; usage ;  exit 1)
    dsidm localhost -b "${_basedn}"  account change_password uid=${2},ou=people,dc=mydemo,dc=lab $3 
    ;;
  *)
    usage
    exit 1
    ;;
esac


