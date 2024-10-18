#!/bin/bash
# Collection of functions to work with disks on Linux

#######################################
# Create file and binds it to a loop device
# Arguments:
#   File name
#   Size file (number of blocks)
#   Look device
# Examples:
#   linux_create_fileAndLoopDevice '/loop-file1' '10240' '/dev/loop1'
#######################################
linux_create_fileAndLoopDevice() {
  local fileName=$1
  local sizeFile=$2
  local loopDevice=$3

  echo "Creating local file ${fileName} and look device ${fileName}..."

  # prepare file for use with loopback device (creates a file filled with zero bytes)
  dd if=/dev/zero of=${fileName} bs=1M count=${sizeFile} status=progress

  # binds the file to the loop device (enabling to work with the file as if it were a block device, like a physical disk)
  losetup ${loopDevice} ${fileName}
}
