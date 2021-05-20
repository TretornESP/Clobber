#!/bin/bash

#Clobber bash script by xabier.iglesias.perez@udc.es
#Cleans everything and erases all data, only for development
#USING THIS IN PRODUCTION WILL CREATE HAVOC

read -r -p "This will delete EVERYTHING and cannot be undone. Are you sure? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY])
    ssh root@10.10.24.3 "bash /Clobber/storage_scripts/cleanup.sh"
    ssh root@10.10.24.2 "bash /Clobber/docker_scripts/cleanup.sh"
    echo "Wiping completed"

        ;;
    *)
        exit
        ;;
esac
