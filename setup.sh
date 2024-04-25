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
# cf-secret encrypt -H 192.168.56.10,192.168.56.7,192.168.56.20 -o /home/vagrant/secret.dat -
ssh ubuntu-20 sudo chown vagrant /home/vagrant/secret.dat
scp ubuntu-20:secret.dat simple/
git add simple/secret.dat
git commit -m 'updated secret'
git push

cf-remote sudo -H server,clients "/var/cfengine/bin/cf-agent -K"

wait "install enterprise hub on ubuntu-22..."
cf-remote install --hub hub --bootstrap 192.168.56.22

wait "login to mission portal and setup VCS..."
cf-remote scp -H hub cfe 
cf-remote sudo -H hub "cp /home/vagrant/cfe /usr/bin/cfe; chmod +x /usr/bin/cfe"
cf-remote sudo -H hub cfe

wait "upgrade debian-10 to enterprise..."
cf-remote uninstall -H debian-10
cf-remote install --clients debian-10 --bootstrap 192.168.56.22
cf-remote sudo -H debian-10 cfe

wait "upgrade centos-7 to enterprise and rebootstrap..."
cf-remote uninstall -H centos-7
cf-remote install --clients centos-7 --bootstrap 192.168.56.7
cf-remote sudo -H centos-7 cfe
