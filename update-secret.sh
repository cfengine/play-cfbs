ssh ubuntu-20 sudo chown vagrant /home/vagrant/secret.dat
scp ubuntu-20:secret.dat simple/
git add simple/secret.dat
git commit -m 'updated secret'
git push
cf-remote sudo -H server "/var/cfengine/bin/cf-agent -K"
cf-remote sudo -H clients "/var/cfengine/bin/cf-agent -K"
