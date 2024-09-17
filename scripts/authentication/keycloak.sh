#!/bin/bash

#######################################
# Login to Keycloak and get an access token
# Globals:
#  SSO_ACCESS_TOKEN
# Arguments:
#   kc_url (Keycloak)
#   kc_realm (Keycloak)
#   kc_client_id (Keycloak)
#   kc_client_secret (Keycloak)
#   kc_username (Keycloak)
#   kc_password (Keycloak)
# Examples:
#   keycloak_login https://sso.suse.com instruqt suse xxxxxx admin password
#######################################
keycloak_login() {
    local kc_url=$1
    local kc_realm=$2
    local kc_client_id=$3
    local kc_client_secret=$4
    local kc_username=$5
    local kc_password=$6

    local response
    response=$(curl -s -X POST "$kc_url/realms/$kc_realm/protocol/openid-connect/token" \
        -H 'Content-Type: application/x-www-form-urlencoded' \
        --data-urlencode "client_id=$kc_client_id" \
        --data-urlencode "client_secret=$kc_client_secret" \
        --data-urlencode "username=$kc_username" \
        --data-urlencode "password=$kc_password" \
        --data-urlencode 'grant_type=password')

    echo $response | jq -r .access_token
}

#######################################
# Create a user in Keycloak
# Arguments:
#   kc_url (Keycloak)
#   kc_realm (Keycloak)
#   kc_access_token (Keycloak)
#   username
#   password
# Examples:
#   keycloak_create_user https://sso.suse.com instruqt $SSO_ACCESS_TOKEN user password group
#######################################
keycloak_create_user() {
  local kc_url=$1
  local kc_realm=$2
  local kc_access_token=$3
  local username=$4
  local password=$5
  local group=$6

  local user_request
  user_request=$(cat <<EOF
  {
    "username": "$username",
    "enabled": true,
    "emailVerified": true,
    "requiredActions": [],
    "email": "$username@instruqt.suse.io",
    "groups": ["$group"],
    "credentials": [
      {
        "type": "password",
        "value": "$password"
      }
    ]
  }
EOF
  )

  curl -s -X POST "$kc_url/admin/realms/$kc_realm/users" \
    -H "Authorization: Bearer $kc_access_token" \
    -H 'Content-Type: application/json' \
    --data-binary "$user_request"
}

#######################################
# Delete a user in Keycloak
# Arguments:
#   kc_url (Keycloak)
#   kc_realm (Keycloak)
#   kc_access_token (Keycloak)
#   username
# Examples:
#   keycloak_delete_user https://sso.suse.com instruqt $SSO_ACCESS_TOKEN user
#######################################
keycloak_delete_user() {
  local kc_url=$1
  local kc_realm=$2
  local kc_access_token=$3
  local username=$4

  local user_id
  user_id=$(curl -s -X GET "$kc_url/admin/realms/$kc_realm/users?username=$username" \
    -H "Authorization: Bearer $kc_access_token" | jq -r .[0].id)

  curl -s -X DELETE "$kc_url/admin/realms/$kc_realm/users/$user_id" \
    -H "Authorization: Bearer $kc_access_token"
}
