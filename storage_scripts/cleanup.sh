#!/bin/bash

#Clobber bash script by xabier.iglesias.perez@udc.es
#Deletes everything, causes grief and ruin

no=$(tgtadm --lld iscsi --op show --mode target | grep ^Target | tail -1 | cut -d' ' -f2)
no=${no::-1}
for i in $(seq 1 $no);
do
  tgtadm --lld iscsi --op delete --force --mode target --tid $i
  echo "Deleted target $i"
done

rm /fs/*
echo "Deleted all fs files"
echo "iSCSI server wipe done"
