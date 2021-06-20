#!/bin/bash

#Clobber bash script by xabier.iglesias.perez@udc.es
#Deletes an specified target
#Params username to delete
#Notes: ALSO DELETES STORAGE!!
#Notes: UNTESTED!!

no=$(tgtadm --lld iscsi --op show --mode target | grep ^Target | grep $1 | awk '{print substr($2, 1, 1)}')
tgtadm --lld iscsi --op delete --force --mode target --tid $no
rm /fs/$1
