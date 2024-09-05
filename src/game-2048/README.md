# 2048 game

[![Docker Image Version](https://img.shields.io/docker/v/devprofr/game-2048?label=Docker)](https://hub.docker.com/r/devprofr/game-2048)

Let's play 2048 Game web application in a container!

💡 This is a hard fork of [gabrielecirulli/2048](https://github.com/gabrielecirulli/2048) which hasn't been updated since 2017.

## How to edit

If you want to modify the CSS, edit the SCSS files present in `style/`: `main.scss` and others. Don't edit the `main.css`, because it's supposed to be generated.

In order to compile your SCSS modifications, you need to use the `sass` gem (install it by running `gem install sass` once Ruby is installed). To run SASS, simply use the following command:

```bash
sass --unix-newlines --watch style/main.scss
```

SASS will automatically recompile your css when changed.

## How to run locally

Build a new container image:

```bash
docker build . -t game2048:local --no-cache
```

Run a container locally:

```bash
docker run --rm -p 8080:80 game2048:local
```

Open [localhost:8080](http://localhost:8080) et enjoy 😁

## How to deploy

The recommanded way to deploy and run is through Helm with the [associated chart](https://github.com/devpro/helm-charts/tree/main/charts/game-2048).
