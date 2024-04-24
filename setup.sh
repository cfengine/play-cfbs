#!/usr/bin/env bash
set -ex

echo -n "Ready to cleanup cf-remote and uninstall everything..."
read -r wait

cf-remote destroy --all

policy_server=ubuntu-20
policy_server_ip=192.168.56.20

cf-remote save --role hub --name $policy_server --hosts vagrant@$policy_server
cf-remote sudo -H $policy_server "apt install -y python3-pip; pip3 install cfbs"

clients="debian-10 centos-7"
for client in $clients; do
  cf-remote save --role client --name $client --hosts vagrant@$client
done

hosts="$policy_server $clients"
for host in $hosts; do
  cf-remote uninstall -H $host
done

echo -n "Done uninstalling. Next is community install..."
read -r wait

cf-remote install --edition community --clients $policy_server --bootstrap $policy_server_ip
cf-remote sudo -H $policy_server "curl --silent https://raw.githubusercontent.com/cfengine/core/master/contrib/masterfiles-stage/install-masterfiles-stage.sh --remote-name"
cf-remote sudo -H $policy_server "chmod +x install-masterfiles-stage.sh"
cf-remote sudo -H $policy_server "./install-masterfiles-stage.sh"
cf-remote scp -H $policy_server params.sh 
cf-remote sudo -H $policy_server "cp /home/vagrant/params.sh /opt/cfengine/dc-scripts/"
cf-remote sudo -H $policy_server "/var/cfengine/httpd/htdocs/api/dc-scripts/masterfiles-stage.sh --DEBUG"
cf-remote scp -H $policy_server cfe 
cf-remote sudo -H $policy_server "cp /home/vagrant/cfe /usr/bin/cfe; chmod +x /usr/bin/cfe"
cf-remote sudo -H $policy_server cfe

for client in $clients; do
  cf-remote install --edition community --clients $client --bootstrap $policy_server_ip
  cf-remote scp -H $client cfe
  cf-remote sudo -H $client "cp /home/vagrant/cfe /usr/bin/cfe; chmod +x /usr/bin/cfe"
done

echo -n "Community installed and bootstrapped. Play around a bit with the Policy. Next is install Enterprise Hub..."
read -r wait

hub=ubuntu-22
hub_ip=192.168.56.22
cf-remote save --role hub --name $hub --hosts vagrant@$hub
cf-remote install --hub $hub --bootstrap $hub_ip

echo -n "Enterprise hub installed. Go to Mission Portal and configure VCS settings... https://192.168.56.202/settings/vcs"
read -r wait

cf-remote sudo -H $policy_server "/var/cfengine/httpd/htdocs/api/dc-scripts/masterfiles-stage.sh --DEBUG"
cf-remote scp -H $hub cfe
cf-remote sudo -H $hub "cp /home/vagrant/cfe /usr/bin/cfe; chmod +x /usr/bin/cfe"
cf-remote sudo -H $hub cfe

echo -n "Enterprise hub should have our policy now. Next is to uninstall community, install enterprise, bootstrap clients..."
read -r wait

for client in $clients; do
  cf-remote uninstall -H $client
  cf-remote install --clients $client --bootstrap $hub_ip
  cf-remote sudo -H $client cfe
done

echo "That's it. Play around. Make sure things look OK."
