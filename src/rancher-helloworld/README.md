# Rancher Hello World

[![Badge](https://badgen.net/static/Container%20Image/GitHub%20Packages/green)](https://github.com/SUSE/lab-setup/pkgs/container/rancher-helloworld)

This small web application is interesting as a first workload to install in a Kubernetes cluster. It shows data about hostname, services and request headers.

💡 This is a hard fork of [rancher/hello-world](https://github.com/rancher/hello-world) which hasn't been updated since 2018.

## Quickstart with a container

If you have a container engine running, you can start right away with the image:

```bash
docker run --rm -p 8080:80 ghcr.io/suse/rancher-helloworld
```

Open the [web application](http://localhost:8080/) and look at the information!

## Deploy in an environment

The recommanded way to run the application is to deploy in a Kubernetes cluster with with the [Helm chart](https://github.com/SUSE/lab-setup/tree/main/charts/rancher-helloworld).

### Develop locally

Update the dependencies (if a change has been made):

```bash
go mod tidy
```

Build the application:

```bash
go build
```

Start the web server:

````bash
HTTP_PORT=8080 ./rancher-helloworld
````

Open [localhost:8080](http://localhost:8080)

## Run from the sources

The container image is using [SUSE BCI (Base Container Images)](https://registry.suse.com/).

Build a local image:

```bash
docker build -t rancher-helloworld .
```

Start a container:

```bash
docker run --rm -p 8080:80 rancher-helloworld
```

Open [localhost:8080](http://localhost:8080)
