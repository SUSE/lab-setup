#!/bin/bash
# Collection of functions to register on SUSE Linux distributions

#######################################
# Register Cloud guest on SUSE Linux
# Examples:
#   suselinux_register_cloudguest
#######################################
suselinux_register_cloudguest() {
  registercloudguest --force-new
  # temporary workaround (the file is generated registercloudguest and prevents further container image pulling)
  rm ~/.docker/config.json
}
