# pauses in stages
#!/usr/bin/env bash
set -ex
server=testhub
cf-remote destroy --all
cf-remote save --role hub --name $server --hosts vagrant@$server
cf-remote sudo -H $server "apt install -y python3-pip; pip3 install cfbs"

clients="debian-10 centos-7"
for client in $clients; do
  cf-remote save --role client --name $client --hosts vagrant@$client
done

hosts="$server $clients"
policy_server_ip=192.168.56.202

for host in $hosts; do
  cf-remote uninstall -H $host
done

cf-remote install --edition community --clients $server --bootstrap $policy_server_ip
cf-remote sudo -H $server "curl --silent https://raw.githubusercontent.com/cfengine/core/master/contrib/masterfiles-stage/install-masterfiles-stage.sh --remote-name"
cf-remote sudo -H $server "chmod +x install-masterfiles-stage.sh"
cf-remote sudo -H $server "./install-masterfiles-stage.sh"
cf-remote scp -H $server params.sh 
cf-remote sudo -H $server "cp /home/vagrant/params.sh /opt/cfengine/dc-scripts/"
cf-remote sudo -H $server "/var/cfengine/httpd/htdocs/api/dc-scripts/masterfiles-stage.sh --DEBUG"
cf-remote scp -H $server cfe 
cf-remote sudo -H $server "cp /home/vagrant/cfe /usr/bin/cfe; chmod +x /usr/bin/cfe"
cf-remote sudo -H $server cfe

for client in $clients; do
  cf-remote install --edition community --clients $client --bootstrap $policy_server_ip
done
