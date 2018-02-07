# Docker radicale (servercontainers/radicale)
_maintained by ServerContainers_

[FAQ - All you need to know about the servercontainers Containers](https://marvin.im/docker-faq-all-you-need-to-know-about-the-marvambass-containers/)

## What is it

This Dockerfile (available as ___servercontainers/radicale___) gives you a radicale server with git versioning.

It's based on the [_/python:3.6-alpine](https://registry.hub.docker.com/_/python/) Image

View in Docker Registry [servercontainers/radicale](https://registry.hub.docker.com/u/servercontainers/radicale/)

View in GitHub [ServerContainers/radicale](https://github.com/ServerContainers/radicale)

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
