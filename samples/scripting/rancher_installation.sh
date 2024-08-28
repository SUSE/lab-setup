#!/bin/bash

# downloads shared scripts
curl -sfL https://raw.githubusercontent.com/SUSE/lab-setup/feature/init-solution/scripts/download.sh \
  | GIT_REVISION=refs/heads/feature/init-solution sh -

# references shares scripts
source lab-setup/scripts/index.sh

wait_for_cluster_availability
