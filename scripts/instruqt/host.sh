#!/bin/bash
# Collection of functions to work with hosts in Instruqt

#######################################
# Wait for host startup
# Examples:
#   instruqt_wait_hoststartup
#######################################
instruqt_wait_hoststartup() {
  # waits for Instruqt host bootstrap to finish
  until [ -f /opt/instruqt/bootstrap/host-bootstrap-completed ]
  do
    sleep 1
  done
}
