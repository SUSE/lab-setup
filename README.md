# Lab Setup

[![CI](https://github.com/SUSE/lab-setup/actions/workflows/ci.yml/badge.svg?branch=develop)](https://github.com/SUSE/lab-setup/actions/workflows/ci.yml)
[![PKG](https://github.com/SUSE/lab-setup/actions/workflows/pkg.yml/badge.svg?branch=main)](https://github.com/SUSE/lab-setup/actions/workflows/main.yml)

Welcome! You'll find in this repository everything needed to setup a lab environment from open-source components.

It is used internally at SUSE but is open to everyone. Feel free to [contribute](CONTRIBUTING.md) and share feedback!

## Getting started

Wether you're looking for simple way to automate an infrastructure or running demo workload, we've got you covered!

### Bash scripting

Download and source the files (targetting `develop` branch):

```bash
curl -sfL https://raw.githubusercontent.com/SUSE/lab-setup/develop/scripts/download.sh | sh -s -- -o temp
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

### Container images

Use the container images we provide for our demonstrations, for instance:

```bash
docker run --rm -p 8080:8080 ghcr.io/suse/cow-demo
```

Open the [web application](http://localhost:8080/) and enjoy the live display!

Browse the [catalog of applications](src/README.md).
