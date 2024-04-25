#!/usr/bin/env bash
set -ex

function wait
{
  set +x
  echo -n "$@"
  read -r _r
  set -x
}

wait "install enterprise hub on ubuntu-22..."
cf-remote install --hub hub --bootstrap 192.168.56.22

echo "https://192.168.56.22/settings/vcs enter VCS type: GIT+CFBS, URL: https://github.com/craigcomstock/play-cfbs and refspec: simple"
echo "add class to hub in MP UI: default:cfengine_internal_masterfiles_update"
wait "login to mission portal and setup VCS..."
cf-remote scp -H hub cfe 
cf-remote sudo -H hub "cp /home/vagrant/cfe /usr/bin/cfe; chmod +x /usr/bin/cfe"
cf-remote sudo -H hub cfe
