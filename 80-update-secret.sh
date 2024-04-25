#!/usr/bin/env bash
set -ex

function wait
{
  set +x
  echo -n "$@"
  read -r _r
  set -x
}

wait "re-encrypt secret for enterprise hub and clients..."
ssh ubuntu-22 sudo chown vagrant /home/vagrant/secret.dat
scp ubuntu-22:secret.dat simple/
git add simple/secret.dat
git commit -m 'updated secret'
git push
cf-remote sudo -H hub "/var/cfengine/bin/cf-agent -K"
cf-remote sudo -H clients "/var/cfengine/bin/cf-agent -K"
