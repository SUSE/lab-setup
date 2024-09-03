#!/bin/bash
# File to be sourced to have all shell functions available in the bash terminal

SCRIPT_FOLDER=$(dirname "${BASH_SOURCE[0]}")
for file in ${SCRIPT_FOLDER}/*/*.sh
do {
  echo "Sourcing ${file}"
  . $file
}
done
