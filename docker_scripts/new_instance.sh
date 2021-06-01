#!/bin/bash

#Clobber bash script by xabier.iglesias.perez@udc.es
#Launches a new clobber instance for the user
#Params:
#  Username
#Outputs:
#  ip of the instance
#WARNING: Storage for the user must be online before calling this script!!!

if [ "$#" -ne 1 ]; then
    echo "Illegal number of parameters"
    echo "Usage ./new_instance.sh name"
    exit 1
fi

iscsiadm --mode node --targetname iqn.com.clobber:$1 --portal 10.10.24.3:3260 -u
echo "loged out of previous session just in case"
iscsiadm --mode discovery --type sendtargets --portal 10.10.24.3
iscsiadm --mode node --targetname iqn.com.clobber:$1 --portal 10.10.24.3:3260 --login
dev=$(lsscsi -t | grep iqn.com.clobber:$1 | grep '/dev/' | awk '{print $NF}')
echo "New device registered under $dev"
mkdir -p /fs/$1
mount $dev /fs/$1
echo "Device mounted in /fs/$1"
id=$(docker run -d -p 0.0.0.0:5000-6000:5000 -p 0.0.0.0:52022-53022:22 --name $1 --volume /fs/$1:/home/clobber/cdata --volume /Clobber/python/app/src/:/server clobber)
#id=$(docker run -d -p 0.0.0.0:5000-6000:5000 -p 0.0.0.0:52022-53022:22 --name $1 --volume /fs/$1:/home/clobber/cdata clobber) #Swap comments for production
ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $id)
port=$(docker port $1)
#port=${port##*:}
echo "Instance $1 is up, internal ip: $ip"
echo "$port"
echo "Login command: ssh -p [ssh port] clobber@10.10.24.2"
echo "Default password: clobber"
