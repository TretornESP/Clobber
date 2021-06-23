#!/bin/bash
#
#
#Clobber bash script by xabier.iglesias.perez@udc.es
#Creates dummy fs files
#
#Params:
#size of file

if [ "$#" -ne 1 ]; then
    echo "Illegal number of parameters"
    echo "Usage ./preload.sh size"
    exit 1
fi


dd if=/dev/zero of=/rootfs/$1 bs=1M count=$1
mkfs -t ext4 /rootfs/$1

ls -lsart /rootfs/$1
