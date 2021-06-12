#!/bin/bash

#Clobber bash script by xabier.iglesias.perez@udc.es
#Launches a new clobber instance for the user
#Params:
#  source ip
#  associated port
#  living time
#Outputs:
#ErrLVL:

iptables -A INPUT -s $1 -p tcp --dport $2 -i enp0s3 -j ACCEPT
echo "iptables -A INPUT -s $1 -p tcp --dport $2 -i enp0s3 -j DROP" | at now +$3 minutes
