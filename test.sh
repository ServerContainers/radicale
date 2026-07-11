#!/bin/sh
# automated smoke test for the radicale container
# builds the image, starts it standalone and asserts radicale actually serves
# CalDAV/CardDAV (real DAV replies, not just an open port)
set -eu

IMAGE=radicale-test
NAME=radicale-test-run
PORT=8000

FAILED=0
fail() {
  echo "FAIL: $*" >&2
  FAILED=1
}

cleanup() {
  echo ">> cleanup: removing container $NAME"
  docker rm -f "$NAME" >/dev/null 2>&1 || true
}
trap cleanup EXIT INT TERM

# send a raw HTTP request to radicale (inside the container, via busybox nc)
# and print the response. usage: http_req <method> [extra header lines...]
http_req() {
  _method="$1"
  docker exec "$NAME" sh -c "printf '$_method / HTTP/1.1\r\nHost: localhost\r\nDepth: 0\r\nContent-Length: 0\r\nConnection: close\r\n\r\n' | nc 127.0.0.1 $PORT" 2>/dev/null || true
}

echo ">> building image $IMAGE"
docker build -t "$IMAGE" .

echo ">> (re)starting container $NAME"
docker rm -f "$NAME" >/dev/null 2>&1 || true
# minimal env: radicale needs no config to start (anonymous, filesystem storage)
docker run -d --name "$NAME" "$IMAGE"

echo ">> waiting for radicale to answer on :$PORT (up to ~40s)"
READY=0
i=0
while [ "$i" -lt 20 ]; do
  if ! docker ps --format '{{.Names}}' | grep -q "^${NAME}$"; then
    echo "!! container is not running anymore, dumping logs:" >&2
    docker logs "$NAME" >&2 2>&1 || true
    fail "container exited during startup"
    break
  fi
  if http_req OPTIONS | grep -q '^HTTP/'; then
    READY=1
    break
  fi
  i=$((i + 1))
  sleep 2
done

if [ "$READY" -ne 1 ] && [ "$FAILED" -eq 0 ]; then
  echo "!! radicale did not answer in time, dumping logs:" >&2
  docker logs "$NAME" >&2 2>&1 || true
  fail "timed out waiting for radicale to respond"
fi

# only run the deeper assertions if the container is still up
if docker ps --format '{{.Names}}' | grep -q "^${NAME}$"; then

  echo ">> assert: container is running"
  docker ps --format '{{.Names}}' | grep -q "^${NAME}$" \
    && echo "ok - container running" || fail "container not running"

  echo ">> assert: radicale process present"
  if docker exec "$NAME" ps aux | grep -q '[r]adicale'; then
    echo "ok - radicale process running"
  else
    fail "radicale process not found"
  fi

  # OPTIONS is the DAV capability probe. a plain port-open check would pass on
  # anything; here we require the DAV: header advertising calendar-access and
  # addressbook, which only a CalDAV/CardDAV server (radicale) sends back.
  echo ">> assert: OPTIONS returns 200 with CalDAV/CardDAV DAV header"
  OPTIONS_RESP=$(http_req OPTIONS)
  if echo "$OPTIONS_RESP" | grep -q '^HTTP/1.[01] 200'; then
    echo "ok - OPTIONS returned 200"
  else
    fail "OPTIONS did not return 200 (got: '$(echo "$OPTIONS_RESP" | head -n1)')"
  fi
  if echo "$OPTIONS_RESP" | grep -qi '^DAV:.*calendar-access' \
     && echo "$OPTIONS_RESP" | grep -qi '^DAV:.*addressbook'; then
    echo "ok - DAV header advertises calendar-access + addressbook"
  else
    fail "OPTIONS response missing CalDAV/CardDAV DAV header"
  fi

  echo ">> assert: Allow header lists DAV methods (PROPFIND, REPORT, MKCALENDAR)"
  if echo "$OPTIONS_RESP" | grep -qi '^Allow:.*PROPFIND' \
     && echo "$OPTIONS_RESP" | grep -qi '^Allow:.*REPORT' \
     && echo "$OPTIONS_RESP" | grep -qi '^Allow:.*MKCALENDAR'; then
    echo "ok - Allow header lists DAV methods"
  else
    fail "OPTIONS Allow header missing DAV methods"
  fi

  # PROPFIND is a real DAV method; the default config requires auth for it, so
  # radicale answers with its own Basic realm. this proves it is actually
  # processing DAV requests (and is radicale), not merely accepting a socket.
  echo ">> assert: PROPFIND is handled and challenges with the Radicale realm"
  PROPFIND_RESP=$(http_req PROPFIND)
  if echo "$PROPFIND_RESP" | grep -q '^HTTP/1.[01] 401' \
     && echo "$PROPFIND_RESP" | grep -qi 'WWW-Authenticate: Basic realm="Radicale'; then
    echo "ok - PROPFIND challenged with Radicale Basic realm"
  else
    fail "PROPFIND did not return a Radicale auth challenge (got: '$(echo "$PROPFIND_RESP" | head -n1)')"
  fi

fi

echo
if [ "$FAILED" -eq 0 ]; then
  echo "ALL TESTS PASSED"
  exit 0
else
  echo "SOME TESTS FAILED"
  exit 1
fi
