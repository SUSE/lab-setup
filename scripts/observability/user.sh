#!/bin/bash

observability_keycloak_login() {
    kc_url=$1
    kc_realm=$2
    kc_client_id=$3
    kc_client_secret=$4
    kc_username=$4
    kc_password=$5

    response=$(curl -s -X POST "$kc_url/realms/$kc_realm/protocol/openid-connect/token" \
        -H 'Content-Type: application/x-www-form-urlencoded' \
        --data-urlencode "client_id=$kc_client_id" \
        --data-urlencode "client_secret=$kc_client_secret" \
        --data-urlencode "username=$kc_username" \
        --data-urlencode "password=$kc_password" \
        --data-urlencode 'grant_type=password')

    access_token=$(echo $response | jq -r .access_token)

    echo $access_token
}

observability_create_user() {
  kc_url=$1
  kc_realm=$2
  kc_access_token=$3
  username=$4
  password=$5

  user_request=$(cat <<EOF
  {
    "username": "$username",
    "enabled": true,
    "emailVerified": true,
    "requiredActions": [],
    "email": "$username@instruqt.suse.io",
    "groups": ["/stackstate-k8s-troubleshooter"],
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

observability_delete_user() {
  kc_url=$1
  kc_realm=$2
  kc_access_token=$3
  username=$4

  user_id=$(curl -s -X GET "$kc_url/admin/realms/$kc_realm/users?username=$username" \
    -H "Authorization: Bearer $kc_access_token" | jq -r .[0].id)

  curl -s -X DELETE "$kc_url/admin/realms/$kc_realm/users/$user_id" \
    -H "Authorization: Bearer $kc_access_token"
}
