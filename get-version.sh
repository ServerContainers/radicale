#!/bin/bash
export IMG=$(docker build -q --pull --no-cache -t 'get-version' .)

export RADICALE_VERSION=$(docker run --rm -t get-version pip3 list | grep -i radicale | tr ' ' '\n' | grep '[0-9]\.[0-9]')
export ALPINE_VERSION=$(docker run --rm -t get-version cat /etc/alpine-release | tail -n1 | tr -d '\r')
[ -z "$ALPINE_VERSION" ] && exit 1

export IMGTAG=$(echo "$1""a$ALPINE_VERSION-r$RADICALE_VERSION")
export IMAGE_EXISTS=$(docker pull "$IMGTAG" 2>/dev/null >/dev/null; echo $?)

# return latest, if container is already available :)
if [ "$IMAGE_EXISTS" -eq 0 ]; then
  echo "$1""latest"
else
  echo "$IMGTAG"
fi