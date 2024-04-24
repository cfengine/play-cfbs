server=testhub
clients=debian-10 centos-7
hosts=$server $clients
policy_server_ip=192.168.56.202

for host in $hosts; do
  cf-remote uninstall -H vagrant@$host
done

cf-remote install --edition community --client vagrant@$server --bootstrap $policy_server_ip
cf-remote sudo -H vagrant@$server "curl --silent https://raw.githubusercontent.com/cfengine/core/master/contrib/masterfiles-stage/install-masterfiles-stage.sh --remote-name"
cf-remote sudo -H vagrant@$server "chmod +x install-masterfiles-stage.sh"
cf-remote sudo -H vagrant@$server "./install-masterfiles-stage.sh"
cf-remote scp -H vagrant@$server params.sh /opt/cfengine/dc-scripts/params.sh
cf-remote scp -H vagrant@$server cfe /usr/bin/
cf-remote sudo -H vagrant@$server cfe
exit 0

for client in $clients; do
  cf-remote install --edition community --client vagrant@$client --bootstrap $policy_server_ip
done
