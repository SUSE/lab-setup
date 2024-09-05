# Lab Setup

[![CI](https://github.com/SUSE/lab-setup/actions/workflows/ci.yml/badge.svg?branch=develop)](https://github.com/SUSE/lab-setup/actions/workflows/ci.yml)

Welcome! You'll find in this repository some open-source material to setup a lab environment.

It is used internally at SUSE (the goal being to capitalize and factorize), but is open to everyone. Feel free to contribute and share feedback!

## Getting started

Wether you're looking for simple way to automate an infrastructure or running demo workload, we've got you covered!

### Bash scripting

Download and source the files (targetting `develop` branch):

```bash
curl -sfL https://raw.githubusercontent.com/SUSE/lab-setup/develop/scripts/download.sh | GIT_REVISION=refs/heads/develop sh -s -- -o temp
. temp/scripts/index.sh
```

Call a function:

```bash
k3s_create_cluster v1.23
```

Browse the [catalog of functions](scripts/README.md#shell-functions) and [concrete examples](scripts/README.md#concrete-examples).

### Helm charts

Add Helm repository:

```bash
helm repo add suse-lab-setup https://opensource.suse.com/lab-setup
helm repo update
```

Deploy a chart:

```bash
helm upgrade --install cow-demo suse-lab-setup/cow-demo --namespace demo
```

Browse the [catalog of Helm charts](charts/README.md).
