if [ "$#" -ne 2 ]; then
    echo "Illegal number of parameters"
    echo "Usage ./new.sh size name"
    exit 1
fi

ssh root@10.10.24.3 "bash /Clobber/storage_scripts/new_target.sh $1 $2"
echo "Target created"
ssh root@10.10.24.2 "bash /Clobber/docker_scripts/new_instance.sh $2"
echo "Instance created"
