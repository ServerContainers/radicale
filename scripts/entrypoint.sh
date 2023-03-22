#!/bin/sh
cat <<EOF
################################################################################

Welcome to the ghcr.io/servercontainers/radicale

################################################################################

You'll find this container sourcecode here:

    https://github.com/ServerContainers/radicale

The container repository will be updated regularly.

################################################################################


EOF

echo ">> initialize git"
[ ! -d "/data/.git" ] && /bin/sh -c 'cd /data && git init; git config user.email \"robot@radicale\" && git config user.name \"Radicale Git\"'

echo ">> fix permissions of /data"
chmod a+rwx -R /data

echo ">> CMD: exec docker CMD"
echo "$@"
exec "$@"
