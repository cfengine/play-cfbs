set -ex
cf-secret encrypt -H 192.168.56.10,192.168.56.7,192.168.56.20 -o /home/vagrant/secret.dat -
chown vagrant /home/vagrant/secret.dat
