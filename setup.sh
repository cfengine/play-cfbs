#!/usr/bin/env bash
set -ex

vm up
vm ssh-config

# setup cf-remote names
cf-remote destroy --all # start over each time
cf-remote save --role hub --name server --hosts vagrant@ubuntu-20
cf-remote save --role hub --name hub --hosts vagrant@ubuntu-22
cf-remote save --role clients --name clients --hosts vagrant@debian-10,vagrant@centos-7
cf-remote save --role clients --name all --hosts vagrant@ubuntu-20,vagrant@ubuntu-22,vagrant@debian-10,vagrant@centos-7

# uninstall
cf-remote uninstall -H all

# install community, bootstrap
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

# play around for a bit, setup the secret with cf-secret
# cf-secret encrypt -H 192.168.56.10,192.168.56.7,192.168.56.20 -o /home/vagrant/secret.dat -
ssh ubuntu-20 sudo chown vagrant /home/vagrant/secret.dat
scp ubuntu-20:secret.dat simple/
git add simple/secret.dat
git commit -m 'updated secret'
git push

cf-remote sudo -H server,clients cfe

