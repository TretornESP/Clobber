port=$(ssh root@10.10.24.2 "bash /Clobber/docker_scripts/get_instance.sh $1")
res=$(curl 10.10.24.2:$port/test -m 5)

if [ "$res" == "ext4" ]; then
  echo "Test ok"
else
  echo "[FAILURE] id: $i port:$port res:$res"
fi
