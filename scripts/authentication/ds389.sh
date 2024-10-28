#!/bin/bash
# This library contains some functions to use and setup 389
# directory server ( https://www.port389.org/index.html )
# which is an "enterprise-class Open Source LDAP server for Linux.". 
# SPDX-License-Identifier: GPL-3.0-only or GPL-3.0-or-later
# 
# Copyright (C) 2024 Raul Mahiques
#
# This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
# For more details find a copy of the license here: 
# https://www.gnu.org/licenses/gpl-3.0.txt
#



#######################################
# DS389 - restrict permissions:
#   - prevent normal users from reading the whole directory
# Arguments:
#   1 - _ldap_uri
#   2 - _ldap_basedn
#   3 - _admin_user
#   4 - _admin_pwd
# Examples:
#   ds389_restrict_permissions "<_ldap_uri>" "<_ldap_basedn>" "<_admin_user>" "<_admin_pwd>"
#######################################
function ds389_restrict_permissions() {
  local _ldap_uri="$1"
  local _ldap_basedn="$2"
  local _admin_user="$3"
  local _admin_pwd="$4"
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
# Arguments:
#   1 - _ldap_uri
#   2 - _ldap_basedn
#   3 - _admin_user
#   4 - _admin_pwd
#   5 - Username (Default: ldap_user)
# Examples:
#   ds389_user_private_read "ldap://ldap.mydemo.lab:389" "dc=mydemo,dc=lab" "cn=Directory Manager" "secret" "ldap_user"
#######################################
function ds389_ldap_user-user_private_read() {
  local _ldap_uri="$1"
  local _ldap_basedn="$2"
  local _admin_user="$3"
  local _admin_pwd="$4"
  local ldap_user="$5"
  ldapmodify -D "${_admin_user}" -w "${_admin_pwd}" -x  -H "${_ldap_uri}" << EOL
dn: cn=user_private_read,ou=permissions,${_ldap_basedn}
changetype: modify
add: member
member: uid=${ldap_user},ou=people,${_ldap_basedn}
EOL
}

#######################################
# DS389 - Verify user has access
# Arguments:
#   1 - ldap user DN
#   2 - ldap user pwd
#   3 - _ldap_uri
#   4 - _ldap_basedn
# Examples:
#   ds389_ldap_user_access_check "cn=Directory Manager" "secret"  "uid=ldap_user,ou=people,dc=mydemo,dc=lab" "mypassword"
#######################################
function ds389_ldap_user_access_check() {
  local _ldap_user_dn="${1}"
  local _ldap_user_pwd="${2}"
  local _ldap_uri="${3}"
  local _ldap_basedn="${4}"
  ldapsearch -x  -D "${_ldap_user_dn}" -w "${_ldap_user_pwd}" -H "${_ldap_uri}"  -b "${_ldap_basedn}"
}

#######################################
# DS389 - Install 389 Directory server
# Arguments:
#   1 - _ldap_uri
#   2 - _ldap_basedn
#   3 - _admin_user
#   4 - _admin_pwd
# Examples:
#   ds389_install "ldap://ldap.mydemo.lab:389" "dc=mydemo,dc=lab" "cn=Directory Manager" "secret"
#######################################
function ds389_install() {
  local _ldap_uri="${1}"
  local _ldap_basedn="${2}"
  local _admin_user="${3}"
  local _admin_pwd="${4}"
  # add the repo
  helm repo add suse-lab-setup https://opensource.suse.com/lab-setup
  helm repo update
  # installs the chart with default parameters
  if [[ -f values.yaml ]]
  then
    helm upgrade --install ds389  --namespace ds389 suse-lab-setup/ds389 -f values.yaml
  else
    helm upgrade --install ds389  --namespace ds389 suse-lab-setup/ds389
  fi
  sleep 60
  ds389_restrict_permissions "${_ldap_uri}" "${_ldap_basedn}" "${_admin_user}" "${_admin_pwd}"
  ds389_ldap_user-user_private_read
}

#######################################
# DS389 - Uninstall 389 Directory server
# Examples:
#   ds389_uninstall
#######################################
function ds389_uninstall() {
  helm uninstall ds389
  sleep 15 
}
