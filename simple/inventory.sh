#!/usr/bin/env bash
for client_ip in $(cf-key -s | grep Incoming | awk '{print $2}'); do
  echo "client ip: $client_ip"
  for dir in $(cf-net -H $client_ip opendir /var/cfengine/data | grep -v '^\.'); do
    for file in $(cf-net -H $client_ip opendir /var/cfengine/data/$dir | grep -v '^\.'); do
      mkdir -p /var/cfengine/data/$dir
      cd /var/cfengine/data/$dir
      cf-net -H $client_ip get /var/cfengine/data/$dir/$file
    done
  done
done
