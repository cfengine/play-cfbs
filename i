rm -rf out
cfbs build
cfengine lint out/masterfiles/update.cf
cfengine lint out/masterfiles/promises.cf
