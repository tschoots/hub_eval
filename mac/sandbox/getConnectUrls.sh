#!/bin/bash

echo  -e "\033[5m \033[4m \033[1murls connect to the dockerized hub : \033[0m"
declare -a urls=($(VBoxManage showvminfo boot2docker-vm | grep NIC | grep hub | awk '{print "http://" $13 ":"  $17}' | sed 's/,//g'))
for url in "${urls[@]}"
do
   echo $url
done
