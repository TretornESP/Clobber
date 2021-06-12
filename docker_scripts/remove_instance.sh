#!/bin/bash

#Clobber bash script by xabier.iglesias.perez@udc.es
#Deletes specified hook to the storage server
#This is not as tragic as server side cleanup, but use carefully also
#Params:
#  Username

if [ "$#" -ne 1 ]; then
    echo "Illegal number of parameters"
    echo "Usage ./new_instance.sh name"
    exit 1
fi

docker stop $1
docker rm $1
echo "docker container has been stopped"
iscsiadm --mode node --targetname iqn.com.clobber:$1 --portal 10.10.24.3:3260 -u
echo "iSCSI logout completed"
while read -r mountpoint; do
    umount $mountpoint
done < <(awk '{print $2}' < /proc/mounts | grep '^/fs/')
sudo rm -rf /fs
echo "mount directory cleaned"
