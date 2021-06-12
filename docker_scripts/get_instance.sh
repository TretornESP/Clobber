#!/bin/bash

#Clobber bash script by xabier.iglesias.perez@udc.es
#Gets info of a running instance
#Params:
#  Username
#Output:
# The ip and port of the container for the web access
# ErrLVL:
#  0 Ok, 1 Invalid args, 2 Port error

if [ "$#" -ne 1 ]; then
    echo "Illegal number of parameters"
    echo "Usage ./get_instance.sh name"
    exit 1
fi

if [ "$( docker container inspect -f '{{.State.Status}}' $1 )" != "running" ]
then
  echo "Container not running!"
  exit 2
fi

id=$(docker ps -aqf "name=$1")
ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $id)
port2=$(docker port $1|sed -n '2 p') #Sed is only for debugging while ssh is on
port1=$(docker port $1|sed -n '1 p') #Sed is only for debugging while ssh is on
port1=${port1##*:}
port2=${port2##*:}

if [ "$port1" -gt "$port2" ]; then
  if [ "$port2" -ge "5000" ] && [ "$port2" -le "6000" ]; then
    echo "$port2"
    exit 0
  else
    exit 2
  fi
else
  if [ "$port1" -ge "5000" ] && [ "$port1" -le "6000" ]; then
    echo "$port1"
    exit 0
  else
    exit 2
  fi
fi
