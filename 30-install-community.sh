#!/usr/bin/env bash
set -ex

function wait
{
  set +x
  echo -n "$@"
  read -r _r
  set -x
}

wait "install community, bootstrap..."
now=$(date +%s)
cf-remote sudo -H all "date --set=@$now"
cf-remote sudo -H server "apt install -y python3-pip; pip3 install cfbs"
cf-remote install --edition community --clients server --bootstrap 192.168.56.20
cf-remote sudo -H server "curl --silent https://raw.githubusercontent.com/cfengine/core/master/contrib/masterfiles-stage/install-masterfiles-stage.sh --remote-name"
cf-remote sudo -H server "chmod +x install-masterfiles-stage.sh"
cf-remote sudo -H server "./install-masterfiles-stage.sh"
cf-remote scp -H server params.sh 
cf-remote sudo -H server "cp /home/vagrant/params.sh /opt/cfengine/dc-scripts/"
cf-remote sudo -H server "/var/cfengine/httpd/htdocs/api/dc-scripts/masterfiles-stage.sh --DEBUG"
cf-remote scp -H server cfe 
cf-remote sudo -H server "cp /home/vagrant/cfe /usr/bin/cfe; chmod +x /usr/bin/cfe"
cf-remote sudo -H server cfe
cf-remote install --edition community --clients clients --bootstrap 192.168.56.20
