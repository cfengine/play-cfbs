#!/usr/bin/env bash
set -ex

function wait
{
  set +x
  echo -n "$@"
  read -r _r
  set -x
}
vm up
vm ssh-config

wait "setup cf-remote names..."
cf-remote destroy --all # start over each time
cf-remote save --role hub --name server --hosts vagrant@ubuntu-20
cf-remote save --role hub --name hub --hosts vagrant@ubuntu-22
cf-remote save --role clients --name clients --hosts vagrant@debian-10,vagrant@centos-7
cf-remote save --role clients --name all --hosts vagrant@ubuntu-20,vagrant@ubuntu-22,vagrant@debian-10,vagrant@centos-7

wait "uninstall..."
cf-remote uninstall -H all

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

wait "play around for a bit, setup the secret with cf-secret. press enter to pull, commit and push the secret to the repo..."
ssh ubuntu-20 sudo chown vagrant /home/vagrant/secret.dat
scp ubuntu-20:secret.dat simple/
git add simple/secret.dat
git commit -m 'updated secret'
git push
cf-remote sudo -H server "/var/cfengine/bin/cf-agent -K"
cf-remote sudo -H clients "/var/cfengine/bin/cf-agent -K"

wait "install enterprise hub on ubuntu-22..."
cf-remote install --hub hub --bootstrap 192.168.56.22

echo "https://192.168.56.22/settings/vcs enter VCS type: GIT+CFBS, URL: https://github.com/craigcomstock/play-cfbs and refspec: simple"
echo "add class to hub in MP UI: default:cfengine_internal_masterfiles_update"
wait "login to mission portal and setup VCS..."
cf-remote scp -H hub cfe 
cf-remote sudo -H hub "cp /home/vagrant/cfe /usr/bin/cfe; chmod +x /usr/bin/cfe"
cf-remote sudo -H hub cfe

wait "upgrade clients to enterprise..."
cf-remote uninstall -H clients
cf-remote install --clients clients --bootstrap 192.168.56.22
cf-remote sudo -H clients cfe

wait "re-encrypt secret for enterprise hub and clients..."
ssh ubuntu-22 sudo chown vagrant /home/vagrant/secret.dat
scp ubuntu-22:secret.dat simple/
git add simple/secret.dat
git commit -m 'updated secret'
git push
cf-remote sudo -H hub "/var/cfengine/bin/cf-agent -K"
cf-remote sudo -H clients "/var/cfengine/bin/cf-agent -K"

wait "debugging..."
cf-remote sudo -H hub "/var/cfengine/bin/cf-hub --query-host 192.168.56.10 --query rebase"
cf-remote sudo -H hub "/var/cfengine/bin/cf-hub --query-host 192.168.56.10 --query delta"
cf-remote sudo -H hub "/var/cfengine/bin/cf-hub --query-host 192.168.56.7 --query rebase"
cf-remote sudo -H hub "/var/cfengine/bin/cf-hub --query-host 192.168.56.7 --query delta"
cf-remote sudo -H hub "/var/cfengine/bin/cf-hub --query-host 192.168.56.22 --query rebase"
cf-remote sudo -H hub "/var/cfengine/bin/cf-hub --query-host 192.168.56.22 --query delta"

cf-remote sudo -H hub cfe
cf-remote sudo -H clients cfe
