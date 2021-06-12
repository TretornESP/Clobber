#!/bin/bash

#Clobber bash script by xabier.iglesias.perez@udc.es
#Connects to a clobber image
#Params:
#  Username
#Output:
# The url for the container
# ErrLVL:
#  0 Ok, 1 Invalid args, 2 Container down

if [ "$#" -ne 1 ]; then
    echo "Illegal number of parameters"
    echo "Usage ./connect.sh name"
    exit 1
fi

ssh root@10.10.24.2 "bash /Clobber/docker_scripts/get_instance.sh $1"
