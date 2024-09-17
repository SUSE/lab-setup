#!/bin/bash

#######################################
# Install the SUSE Observability CLI
#######################################
observability_install_cli() {
  curl -o- https://dl.stackstate.com/stackstate-cli/install.sh | STS_CLI_LOCATION=/usr/local/bin bash
}
