#!/usr/bin/env bash
set -ex

function wait
{
  set +x
  echo -n "$@"
  read -r _r
  set -x
}

wait "debugging..."
cf-remote sudo -H hub "/var/cfengine/bin/cf-hub --query-host 192.168.56.10 --query rebase"
cf-remote sudo -H hub "/var/cfengine/bin/cf-hub --query-host 192.168.56.10 --query delta"
cf-remote sudo -H hub "/var/cfengine/bin/cf-hub --query-host 192.168.56.7 --query rebase"
cf-remote sudo -H hub "/var/cfengine/bin/cf-hub --query-host 192.168.56.7 --query delta"
cf-remote sudo -H hub "/var/cfengine/bin/cf-hub --query-host 192.168.56.22 --query rebase"
cf-remote sudo -H hub "/var/cfengine/bin/cf-hub --query-host 192.168.56.22 --query delta"

cf-remote sudo -H hub cfe
cf-remote sudo -H clients cfe
