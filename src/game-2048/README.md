# 2048 game

[![Badge](https://badgen.net/static/Container%20Image/GitHub%20Packages/green)](https://github.com/SUSE/lab-setup/pkgs/container/game-2048)

Let's play 2048 game in a browser!

💡 This is a hard fork of [gabrielecirulli/2048](https://github.com/gabrielecirulli/2048) which hasn't been updated since 2017.

## Quickstart with a container

If you have a container engine running, you can start right away with the image:

```bash
docker run --rm -p 8080:80 ghcr.io/suse/game-2048:1.0.10773428519
```

Open the [web application](http://localhost:8080/) and enjoy the game!

## Deploy in an environment

The recommanded way to run the application is to deploy in a Kubernetes cluster with with the [Helm chart](https://github.com/SUSE/lab-setup/tree/main/charts/game-2048).

## Update the application

If you want to modify the CSS, edit the SCSS files present in `style/`: `main.scss` and others. Don't edit the `main.css`, because it's supposed to be generated.

In order to compile your SCSS modifications, you need to use the `sass` gem (install it by running `gem install sass` once Ruby is installed). To run SASS, simply use the following command:

```bash
sass --unix-newlines --watch style/main.scss
```

SASS will automatically recompile your css when changed.

## Run from the sources

Build a new image:

```bash
docker build . -t game-2048 --no-cache
```

Start a container:

```bash
docker run --rm -p 8080:80 game-2048
```

Open [localhost:8080](http://localhost:8080) et enjoy 😁
