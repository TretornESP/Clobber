#!/bin/bash

#Clobber bash script by xabier.iglesias.perez@udc.es
#Creates a new san storage, by default in /fs/
#Params:
#  size of disk in MB
#  name for the disk (MUST BE UNIQUE!!!)
#Outputs:
#  name of the created iscsi target
#    format: iqn.com.clobber:NAME

if [ "$#" -ne 2 ]; then
    echo "Illegal number of parameters"
    echo "Usage ./new_target.sh size name"
    exit 1
fi

if test -f "/rootfs/$1"; then
  echo "using cached storage"
  rsync -a /rootfs/$1 /fs/$2
else
  echo "creating storage"
  dd if=/dev/zero of=/fs/$2 bs=1M count=$1
  mkfs -t ext4 /fs/$2
fi


if ! file /fs/$2 | grep "ext4"; then
    echo "fs file creation error"
    exit 2
fi

no=$(tgtadm --lld iscsi --op show --mode target | grep ^Target | tail -1 | cut -d' ' -f2)
if [ -z "$no" ]; then
  no="0"
else
  no=${no::-1}
fi
next=$(($no+1))

tgtadm --lld iscsi --op new --mode target --tid $next -T iqn.com.clobber:$2
echo "Created target for id $next"
tgtadm --lld iscsi --op new --mode logicalunit --tid $next --lun 1 -b /fs/$2
echo "Attached new disk to target"
tgtadm --lld iscsi --op bind --mode target --tid $next -I ALL
echo "Enabled remote hooking"

echo "iqn.com.clobber:$2"
