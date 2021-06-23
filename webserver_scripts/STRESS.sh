#!/bin/bash
#
#
#Clobber bash script by xabier.iglesias.perez@udc.es
#Stresses the services until they explode.
#Wish we could turn back time! To the good old days!
#
#Params:
#number of iterations
#size of each target in mb (USE AROUND STORAGE_SIZE_IN_MB/iterations )
#timeout for the endpoint in seconds
#folder for log output without final slash

results_loop () {
  rm $4/$1_$2_$3_failures.log
  okay=0
  for i in $(seq 1 $1);
  do
    port=$(ssh root@10.10.24.2 "bash /Clobber/docker_scripts/get_instance.sh stress$i")
    res=$(curl 10.10.24.2:$port/test -m $3)

    if [ "$res" == "ext4" ]; then
      okay=$((okay+1))
    else
      echo -e "[FAILURE] id: $i port:$port res:$res\n" >> $4/$1_$2_$3_failures.log
    fi
  done

  response=$(date +"%T")

  echo ""
  echo "Stress test results"
  echo "-----------------------"
  echo "ITER: $1 SIZE: $2 TOUT: $3"
  echo "-----------------------"
  echo "$okay / $1 machines booted successfully"
  echo "log files $4/$1_$2_$3_failures.log $4/$1_$2_$3_targets.log $4/$1_$2_$3_instances.log"
  echo "-----------------------"
  echo "START: $start"
  echo "TARGT: $targets"
  echo "INSTC: $finish"
  echo "RESPO: $response"
  echo "-----------------------"
  echo "TEST FINISHED"

  read -r -p "Run test again? [y/N] " response
  case "$response" in
      [yY][eE][sS]|[yY])
      results_loop $1 $2 $3 $4
          ;;
      *)
      echo -e "\nCleaning up."
      ssh root@10.10.24.3 "bash /Clobber/storage_scripts/cleanup.sh" > /dev/null 2>&1
      ssh root@10.10.24.2 "bash /Clobber/docker_scripts/cleanup.sh" > /dev/null 2>&1
      echo "Cleanup done!"
      exit 0
          ;;
  esac

}

if [ "$#" -ne 4 ]; then
    echo "Illegal number of parameters"
    echo "Usage ./STRESS.sh iterations size timeout folder"
    exit 1
fi

rm $4/$1_$2_$3_targets.log
rm $4/$1_$2_$3_instances.log
TIMEFORMAT=%R

start=$(date +"%T")
echo "Starting stress test with $1 iterations of size $2"
for i in $(seq 1 $1);
do
  { time ssh root@10.10.24.3 "bash /Clobber/storage_scripts/new_target.sh $2 stress$i" ; } 2>> $4/$1_$2_$3_targets.log
  echo ";" >> $4/$1_$2_$3_targets.log
  echo "storage $i/$1 up"
done

targets=$(date +"%T")
echo "All $i targets created at $targets"

for i in $(seq 1 $1);
do
  { time ssh root@10.10.24.2 "bash /Clobber/docker_scripts/new_instance.sh stress$i" ; } 2>> $4/$1_$2_$3_instances.log
  echo ";" >> $4/$1_$2_$3_instances.log
  echo "instance $i/$1 up"
done

finish=$(date +"%T")
echo "All $i instances created at $finish"

results_loop $1 $2 $3 $4
