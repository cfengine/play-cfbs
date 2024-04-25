#!/usr/bin/env bash
set -ex

function wait
{
  set +x
  echo -n "$@"
  read -r _r
  set -x
}

wait "uninstall..."
cf-remote uninstall -H all
