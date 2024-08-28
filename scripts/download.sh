#!/bin/sh

# Usage:
#   curl ... | ENV_VAR=... sh -
#       or
#   ENV_VAR=... ./download.sh
#
# Example:
#   Downloading scripts from a feature branch in a temp local folder:
#     curl ... | GIT_REVISION=refs/heads/feature/init-solution -o temps sh -
#
# Environment variables:
#   - GIT_REVISION
#     Git revision (refs/heads/develop for a branch, refs/tags/v1.3.1 for a tag, d8b7564fbf91473074e86b598ae06c7e4e522b9f for a commit hashcode)

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

cleanup() {
  rm -f ${GIT_REPO_NAME}.zip
  rm -rf ${GIT_REPO_NAME}-${GIT_FOLDER}
}

{
    verify_system
    setup_env "$@"
    download
    cleanup
}
