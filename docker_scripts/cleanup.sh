#!/bin/bash

#Clobber bash script by xabier.iglesias.perez@udc.es
#Deletes all hooks to the storage server
#This is not as tragic as server side cleanup, but use carefully also
#TODO Delete every docker instance here!!
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)
echo "all docker containers have been stopped"
echo "Client wipe done"
sudo iscsiadm --mode node --logoutall=all #sale de todos los targets
echo "iSCSI logout completed"
while read -r mountpoint; do
    umount $mountpoint
done < <(awk '{print $2}' < /proc/mounts | grep '^/fs/')
sudo rm -rf /fs
echo "mount directory cleaned"
