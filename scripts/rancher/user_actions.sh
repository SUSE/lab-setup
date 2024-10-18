#!/bin/bash
# Collection of functions to make user actions

#######################################
# Log in Rancher with username and password
# Globals:
#   LOGIN_TOKEN
# Arguments:
#   Rancher URL
#   Username
#   Password
# Examples:
#   rancher_login_withpassword rancher.random_string.geek admin somepassword
#######################################
rancher_login_withpassword() {
  local rancherUrl=$1
  local username=$2
  local password=$3

  echo "Logs in Rancher as ${username} with username and password..."
  LOGIN_RESPONSE=$(curl -s -k "$rancherUrl/v3-public/localProviders/local?action=login" \
    -H 'Content-Type: application/json' \
    --data-binary "{
      \"username\": \"$username\",
      \"password\": \"$password\"
    }")
  echo "DEBUG LOGIN_RESPONSE=${LOGIN_RESPONSE}"
  LOGIN_TOKEN=$(echo $LOGIN_RESPONSE | jq -r .token)
}

#######################################
# Update user password for Rancher
# Arguments:
#   Rancher URL
#   token
#   current password
#   new password
# Examples:
#   rancher_update_userpwd rancher.random_string.geek xxxxx currentpwd newpwd
#######################################
rancher_update_password() {
  local rancherUrl=$1
  local token=$2
  local currentPassword=$3
  local newPassword=$4

  echo 'Updates Rancher user password...'
  curl -s -k -H "Authorization: Bearer $token" \
    -H 'Content-Type: application/json' \
    -X POST \
    -d '{
      "currentPassword": "'"$currentPassword"'",
      "newPassword": "'"$newPassword"'"
    }' \
    "$rancherUrl/v3/users?action=changepassword"
}

#######################################
# Create an API key Rancher
# Globals:
#   API_TOKEN
# Arguments:
#   Rancher URL
#   token
#   key description
# Examples:
#   rancher_create_apikey rancher.random_string.geek xxxxx 'Automation API Key'
#######################################
rancher_create_apikey() {
  local rancherUrl=$1
  local token=$2
  local description=$3

  echo 'Creates a Rancher API Key...'
  API_KEY_RESPONSE=$(curl -s -k "$rancherUrl/v3/tokens" \
    -H 'Content-Type: application/json' \
    -H "Authorization: Bearer $token" \
    --data-binary '{
      "type": "token",
      "description": "'"$description"'",
      "ttl": 0
    }')
  echo "DEBUG API_KEY_RESPONSE=${API_KEY_RESPONSE}"
  API_TOKEN=$(echo $API_KEY_RESPONSE | jq -r .token)
  sleep 5
}
