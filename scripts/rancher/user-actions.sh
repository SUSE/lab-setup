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
#   rancher_login_userpwd rancher.random_string.geek admin somepassword
#######################################
rancher_login_userpwd() {
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
rancher_update_userpwd() {
  local rancherUrl=$1
  local token=$2
  local currentPassword=$3
  local newPassword=$4

    # updates admin password
  echo "Updates Rancher admin password..."
  curl -s -k -H "Authorization: Bearer $token" \
    -H 'Content-Type: application/json' \
    -X POST \
    -d '{
          "currentPassword": "'"$currentPassword"'",
          "newPassword": "'"$newPassword"'"
        }' \
    "$rancherUrl/v3/users?action=changepassword" > /dev/null
}
