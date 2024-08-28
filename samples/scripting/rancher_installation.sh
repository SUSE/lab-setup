#!/bin/bash

# downloads shared scripts
revision=d8b7564fbf91473074e86b598ae06c7e4e522b9f
wget https://github.com/SUSE/lab-setup/archive/${revision}.zip -O lab-setup.zip
unzip lab-setup.zip
rm -f lab-setup.zip
mkdir lab-setup
mv lab-setup-${revision}/scripts lab-setup
rm -rf lab-setup-${revision}

# references shares scripts
source lab-setup/scripts/index.sh

wait_for_cluster_availability
