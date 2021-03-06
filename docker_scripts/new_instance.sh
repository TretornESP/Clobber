#!/bin/bash

#Clobber bash script by xabier.iglesias.perez@udc.es
#Launches a new clobber instance for the user
#Params:
#  Username
#Outputs:
#  ip of the instance
#ErrLVL:
# 0 Okey, 1 Invalid Params, 2 Container already online
#WARNING: Storage for the user must be online before calling this script!!!

if [ "$#" -ne 1 ]; then
    echo "Illegal number of parameters"
    echo "Usage ./new_instance.sh name"
    exit 1
fi

if [ "$(docker ps -a | grep $1)" ]
then
  if [ "$( docker container inspect -f '{{.State.Status}}' $1 )" == "running" ]
  then
    echo "Container is already on!"
    exit 2
  fi
fi
#iscsiadm --mode node --targetname iqn.com.clobber:$1 --portal 10.10.24.3:3260 -u
#echo "loged out of previous session just in case"
iscsiadm --mode discovery --type sendtargets --portal 10.10.24.3
iscsiadm --mode node --targetname iqn.com.clobber:$1 --portal 10.10.24.3:3260 --login
dev=$(lsscsi -t | grep iqn.com.clobber:$1 | grep '/dev/' | awk '{print $NF}')
mkdir -p /fs/$1
mount $dev /fs/$1
#docker run -d -p 0.0.0.0:5000-6000:5000 -p 0.0.0.0:52022-53022:22 --name $1 --volume /fs/$1:/home/clobber/cdata --volume /Clobber/python/app/src/:/server clobber
docker run -d -p 0.0.0.0:5000-6000:5000 --name $1 --volume /fs/$1:/home/clobber/cdata --volume /Clobber/python/app/src/:/server clobber

exit 0
