#!/bin/sh
# Script to download a specific version of the scripts from GitHub

# Usage:
#   curl ... | ENV_VAR=... sh -
#       or
#   ENV_VAR=... ./setup.sh
#
# Examples:
#   Downloading scripts from a "develop" branch in a temp local folder "temp":
#     curl -sfL https://raw.githubusercontent.com/SUSE/lab-setup/feature/init-solution/scripts/setup.sh | GIT_REVISION=refs/heads/develop sh -s -- -o temp
#   Downloading scripts from a specific revision "d8b7564fbf91473074e86b598ae06c7e4e522b9f" in the default local folder:
#     curl -sfL https://raw.githubusercontent.com/SUSE/lab-setup/feature/init-solution/scripts/setup.sh | GIT_REVISION=d8b7564fbf91473074e86b598ae06c7e4e522b9f sh -
#   Testing locally the setup script:
#     GIT_REVISION=refs/heads/feature/init-solution ./lab-setup/scripts/setup.sh -o temp
#
# Environment variables:
#   - GIT_REVISION
#     Git revision (refs/heads/<branch-name>, refs/tags/vX.Y.Z for a tag, xxxxxxxxxxxxxxxx for a commit hashcode)
#   - OUTPUT_FOLDER
#     Output folder, where the scripts folder will be created with script directory tree inside, overriden if -o is used

info() {
  echo '[INFO] ' "$@"
}

warn() {
  echo '[WARN] ' "$@" >&2
}

fatal() {
  echo '[ERROR] ' "$@" >&2
  exit 1
}

verify_system() {
  info 'Verify system requirements'
  if ! command -v jq &> /dev/null; then
    fatal 'jq is not installed in the machine'
  fi
}

setup_env() {
  info 'Setup variables'
  case "$1" in
      ("-o")
          OUTPUT_FOLDER=$2
          shift
          shift
      ;;
      (*)
          OUTPUT_FOLDER=${OUTPUT_FOLDER:-'lab-setup'}
      ;;
  esac

  GIT_REVISION=${GIT_REVISION:-'refs/heads/develop'}
  GIT_REPO_NAME='lab-setup'
  GIT_FOLDER=$(echo "$GIT_REVISION" | sed 's/\//-/g' | sed 's/refs-//' | sed 's/heads-//')
}

download() {
  info 'Download scripts'
  wget https://github.com/SUSE/${GIT_REPO_NAME}/archive/${GIT_REVISION}.zip -O ${GIT_REPO_NAME}.zip
  unzip -o ${GIT_REPO_NAME}.zip
  mkdir -p ${OUTPUT_FOLDER}
  if [ -d ${OUTPUT_FOLDER}/scripts ]; then
    info "Delete ${OUTPUT_FOLDER}/scripts"
    rm -rf ${OUTPUT_FOLDER}/scripts
  fi
  mv ${GIT_REPO_NAME}-${GIT_FOLDER}/scripts ${OUTPUT_FOLDER}
}

cleanup() {
  info 'Clean-up'
  rm -f ${GIT_REPO_NAME}.zip
  rm -rf ${GIT_REPO_NAME}-${GIT_FOLDER}
}

{
  verify_system
  setup_env "$@"
  download
  cleanup
}
