# Lab Setup

[![CI](https://github.com/SUSE/lab-setup/actions/workflows/ci.yml/badge.svg?branch=develop)](https://github.com/SUSE/lab-setup/actions/workflows/ci.yml)

Welcome! You'll find in this repository some IT material to help setup your lab environments.

It is used internally at SUSE (the goal being to capitalize and factorize), but is open to everyone. Feel free to contribute and share feedback!

## Getting started

### Bash scripting

* Download and source the files (here targetting `develop` branch but you can chose the revision you want):

```bash
SETUP_FOLDER=lab-setup
curl -sfL https://raw.githubusercontent.com/SUSE/lab-setup/feature/init-solution/scripts/download.sh \
  | GIT_REVISION=refs/heads/develop sh -s -- -o $SETUP_FOLDER
. $SETUP_FOLDER/scripts/index.sh
```

* Try some functions:

```bash
# create a Kubernetes cluster (K3s distribution)
k3s_create_cluster v1.23
```

* Look at concrete examples: [Rancher installation with downstream cluster](samples/scripting/rancher_installation.sh)

* Browse the [catalog of functions](scripts/README.md#shell-functions)
