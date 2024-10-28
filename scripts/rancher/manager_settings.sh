#!/bin/bash
# Collection of functions to update Rancher settings

#######################################
# Set Rancher Server URL setting
# Arguments:
#   Rancher URL
# Examples:
#   rancher_update_serverurl https://rancher.random_string.geek
#######################################
rancher_update_serverurl() {
  local rancherUrl=$1

  echo 'Sets Rancher URL in settings...'
  kubectl patch settings.management.cattle.io server-url --type='merge' --patch '{ "value": "'$rancherUrl'" }'
}
