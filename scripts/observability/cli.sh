#!/bin/bash

#######################################
# Install the SUSE Observability CLI
#######################################
observability_install_cli() {
  local version=${1:-3.1.1}
  if ! [ -x "$(command -v sts)" ]; then
    curl -s -o- https://dl.stackstate.com/stackstate-cli/install.sh | STS_CLI_LOCATION=/usr/local/bin STS_CLI_VERSION=$version bash
  else
    echo ">>> sts CLI already installed"
  fi
}
