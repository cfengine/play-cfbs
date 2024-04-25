set -ex
host_ips=$(cf-key -s | grep 192 | sort -u | awk '{print $2}' | paste -s -d,)
cf-secret encrypt -H $host_ips -o /home/vagrant/secret.dat -
chown vagrant /home/vagrant/secret.dat
