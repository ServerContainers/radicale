#!/bin/sh
echo ">> initialize git"
[ ! -d "/data/.git" ] && /bin/sh -c 'cd /data && git init; git config user.email \"robot@radicale\" && git config user.name \"Radicale Git\"'

echo ">> fix permissions of /data"
chmod a+rwx -R /data

echo ">> start radicale server (:8000)"
exec su -l -s /bin/sh -c "exec python3 -m radicale -H 0.0.0.0:8000 -D --storage-type multifilesystem --storage-filesystem-folder /data --no-storage-filesystem-locking --storage-hook 'cd /data && git add -A && (git diff --cached --quiet || git commit -m \"Changes by \"%(user)s)'" radicale
