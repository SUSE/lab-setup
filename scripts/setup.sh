#!/bin/sh

# Usage:
#   curl ... | ENV_VAR=... sh -
#       or
#   ENV_VAR=... ./download.sh
#
# Examples:
#   Downloading scripts from a feature branch "init-solution" in a temp local folder "temp":
#     curl -sfL https://raw.githubusercontent.com/SUSE/lab-setup/feature/init-solution/scripts/setup.sh | GIT_REVISION=refs/heads/feature/init-solution sh -s -- -o temp
#   Downloading scripts from a specific revision "d8b7564fbf91473074e86b598ae06c7e4e522b9f" in the default local folder:
#     curl -sfL https://raw.githubusercontent.com/SUSE/lab-setup/feature/init-solution/scripts/setup.sh | GIT_REVISION=d8b7564fbf91473074e86b598ae06c7e4e522b9f sh -
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
  if [ -x /usr/bin/git ] || type git > /dev/null 2>&1; then
      return
  fi
  fatal 'Git is not installed in the machine'
}

setup_env() {
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
  wget https://github.com/SUSE/${GIT_REPO_NAME}/archive/${GIT_REVISION}.zip -O ${GIT_REPO_NAME}.zip
  unzip -o ${GIT_REPO_NAME}.zip
  mkdir -p ${OUTPUT_FOLDER}
  mv ${GIT_REPO_NAME}-${GIT_FOLDER}/scripts ${OUTPUT_FOLDER}
}

source_scripts() {
  source ${OUTPUT_FOLDER}/scripts/index.sh
}

cleanup() {
  rm -f ${GIT_REPO_NAME}.zip
  rm -rf ${GIT_REPO_NAME}-${GIT_FOLDER}
}

{
  verify_system
  setup_env "$@"
  download
  source_scripts
  cleanup
}
