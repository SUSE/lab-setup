#!/bin/sh
# Collection of functions to update Rancher settings

#######################################
# Set Rancher Server URL setting
# Arguments:
#   Rancher URL
#   Token
# Examples:
#   rancher_update_serverurl https://rancher.random_string.geek xxxxx
#######################################
rancher_update_serverurl() {
  local rancherUrl=$1
  local token=$2

  echo "Sets Rancher URL in settings..."
  curl -s -k -H "Authorization: Bearer $token" \
    -H 'Content-Type: application/json' \
    -X PUT \
    -d '{
          "value": "'"$rancherUrl"'"
        }' \
    "$rancherUrl/v3/settings/server-url"
}
