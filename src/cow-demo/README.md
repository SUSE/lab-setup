# Cow Demo Application

[![Badge](https://badgen.net/static/Container%20Image/GitHub%20Packages/green)](https://github.com/SUSE/lab-setup/pkgs/container/cow-demo)

Cow Demo is a nice web application, written in Go, used for demonstrating Kubernetes and load balancing.

💡 This is a hard fork of [oskapt/rancher-demo](https://github.com/oskapt/rancher-demo) who hasn't been updated since 2021.
It also took the updates from [bashofmann/rancher-demo](https://github.com/bashofmann/rancher-demo).

## Presentation

It will create a colored icon for each replica within a ReplicaSet and indicate which one most recently served a response.
Replicas which haven't been heard from will begin to fade out, until after a configurable number of seconds they will disappear.
This is useful for demonstrating scaling up/down an upgraded application.

## Quickstart with a container

If you have a container engine running, you can start right away with the image:

```bash
docker run --rm -p 8080:8080 ghcr.io/suse/cow-demo
```

Open the [web application](http://localhost:8080/) and enjoy the interactive display!

## Deploy in an environment

The recommanded way to run the application is to deploy in a Kubernetes cluster with with the [Helm chart](https://github.com/SUSE/lab-setup/tree/main/charts/cow-demo).

## Configuration

Environment variables:

- `TITLE`: sets title in demo app
- `SHOW_VERSION`: show version of app in ui (`VERSION` env var)
- `REFRESH_INTERVAL`: interval in milliseconds for page to refresh (default: 1000)
- `EXPIRE_INTERVAL`: how long a replica can go without being seen before we remove it from the display (default: 10s)
- `REMOVE_INTERVAL`: how long after `EXPIRE_INTERVAL` until we remove the icon (default: 20s)
- `SKIP_ERRORS`: set this to prevent errors from counting
- `METADATA`: extra text at bottom of info area
- `CONTAINER_COLOR`: what color the container background should be (default: black). Valid options are any color from the CSS pallet, including:
  - red
  - orange
  - yellow
  - olive
  - green
  - teal
  - blue
  - violet
  - purple
  - pink
  - black
- `PETS`: The kind of pet shown in each container. Valid options are:
  - cows
  - chameleons
  - cowmeleons

## Local development

### How to test

Run in a terminal:

```bash
go test -v ./...
```

### How to run locally

Update the dependencies (if a change has been made):

```bash
go mod tidy
```

Build the application:

```bash
go build
```

Build web content files (not working for the moment):

```bash
cd ui && npm install
cp -f semantic.theme.config semantic/src/theme.config && mkdir -p semantic/src/themes/app && cp -rf semantic.theme/* semantic/src/themes/app
cd semantic && npx gulp build
mkdir -p ../../static/dist/themes/default/ && cp -f dist/semantic.min.css ../../static/dist/semantic.min.css && cp -f dist/semantic.min.js ../../static/dist/semantic.min.js && cp -r dist/themes/default/assets ../../static/dist/themes/default/
cd ../..
```

Start the web server:

````bash
PETS=chameleons CONTAINER_COLOR=purple ./cow-demo
````

Open [localhost:8080](http://localhost:8080)

### How to run in a container

The container image is using [SUSE BCI (Base Container Images)](https://registry.suse.com/).

Build a local image:

```bash
docker build -t cow-demo .
```

Start a container:

```bash
docker run --rm -p 8080:8080 -e COW_COLOR:purple cow-demo
```

Open [localhost:8080](http://localhost:8080)

## Paths

By default the loaded page will reach back to `/demo` every `REFRESH_INTERVAL` and use the returned information to update the display. Other paths are:

- `/info` - returns some additional information about the replica serving the request
- `/load` - adds a 2s delay to the response from `/info` - use this for putting artificial load on the system and watching the replicas scale

## Backlog

- Upgrade [semantic-ui](https://semantic-ui.com/) ("2.2.13") to 2.4 and make dist folder creation works (to be removed from git)
- Publish arm and arm64 container images

## Dependencies

This application is using [urfave/cli](https://cli.urfave.org/) and [semantic-ui](https://semantic-ui.com/).
