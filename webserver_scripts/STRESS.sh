#!/bin/bash
#
#
#Clobber bash script by xabier.iglesias.perez@udc.es
#Stresses the services until they explode.
#Wish we could turn back time! To the good old days!
#
#Params:
#number of iterations
#size of each target (USE AROUND STORAGE_SIZE_IN_MB/iterations )

start=$(date +"%T")
echo "Starting stress test with $1 iterations of size $2"
for i in $(seq 1 $1);
do
  ssh root@10.10.24.3 "bash /Clobber/storage_scripts/new_target.sh $2 stress$i"
done

targets=$(date +"%T")
echo "All $i targets created at $targets"

for i in $(seq 1 $1);
do
  ssh root@10.10.24.2 "bash /Clobber/docker_scripts/new_instance.sh stress$i"
done

finish=$(date +"%T")
echo "All $i targets created at $finish"

echo "Cleaning up."
ssh root@10.10.24.3 "bash /Clobber/storage_scripts/cleanup.sh"
ssh root@10.10.24.2 "bash /Clobber/docker_scripts/cleanup.sh"
echo "Cleanup done, showing results"

echo
echo "Stress test results: $1 iterations, $2 size"
echo "-----------------------"
echo "START: $start"
echo "TARGT: $targets"
echo "INSTC: $finish"
echo "-----------------------"

echo "Instance created"
