# Docker radicale (ghcr.io/servercontainers/radicale)
_maintained by ServerContainers_

## What is it

This Dockerfile (available as ___ghcr.io/servercontainers/radicale___) gives you a radicale server with git versioning.

It's based on the [_/alpine](https://registry.hub.docker.com/_/alpine/) Image

View in Docker Registry [ghcr.io/servercontainers/radicale](https://ghcr.io/servercontainers/radicale)

View in GitHub [ServerContainers/radicale](https://github.com/ServerContainers/radicale)

## Build & Versioning

You can specify `DOCKER_REGISTRY` environment variable (for example `my.registry.tld`)
and use the build script to build the main container and it's variants for _x86_64, arm64 and arm_

You'll find all images tagged like `a3.15.0-r3.1.8` which means `a<alpine version>-r<radicale version>`.
This way you can pin your installation/configuration to a certian version. or easily roll back if you experience any problems
(don't forget to open a issue in that case ;D).

To build a `latest` tag run `./build.sh release`

## Changelogs

* 2023-03-20
    * github action to build container
    * implemented ghcr.io as new registry
    * switched to `alpine` baseimage

## Setup

Check the `docker-compose.yml` to see how to configure htaccess users. __Use hashed passwords for Production!__
Git versioning is automatically enabled.

_the nginx container has basic auth configured but an exception for /.web/ to make the webfrontend available without authentification (webfrontend asks for authentification)_

## Volumes

- /data
    - storage for vcards/calendars
    - git versioning

## Ports

- 8000
    - plain http
    - no authentification
