#!/bin/bash

port=8080


#find all the boot2docker port forwarding routes and delete them
declare -a routes_to_remove=($(VBoxManage showvminfo boot2docker-vm | grep NIC | grep hub | awk '{print $6}' | sed 's/,//g'))
for r in "${routes_to_remove[@]}"
do
  dr1="VBoxManage modifyvm boot2docker-vm --natpf1 delete ${r}"
  echo $dr1
  `$dr1`
done

# here the routes for all active ip addresses are set
declare -a ipAddresses=($(netstat -p tcp | grep "ESTABLISHED" | awk '{print $4}' | sed 's/\./ /g' | awk '{print $1 "." $2 "." $3 "." $4}' | uniq) '127.0.0.1')
i=0
for ip in "${ipAddresses[@]}"
do
  # make the port forwarding rules to be set in boot2docker-vm
  r1="VBoxManage modifyvm boot2docker-vm --natpf1 hub${i},tcp,${ip},${port},,${port}"
  r2="VBoxManage modifyvm boot2docker-vm --natpf1 hub_console${i},tcp,${ip},7081,,7081"
  echo $r1
  `$r1`
  echo $r2
  `$r2`
  i+=1
done
