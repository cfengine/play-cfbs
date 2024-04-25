#!/usr/bin/env bash
set -ex

function wait
{
  set +x
  echo -n "$@"
  read -r _r
  set -x
}

wait "upgrade clients to enterprise..."
cf-remote uninstall -H clients
cf-remote install --clients clients --bootstrap 192.168.56.22
cf-remote sudo -H clients cfe
