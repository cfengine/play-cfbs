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
