#!/bin/bash

_DOCKER_IMAGE="docker.io/blackduckhub/eval:latest"


function printUrls {
   echo  -e "\033[5m \033[4m \033[1murls connect to the dockerized hub : \033[0m"
   declare -a urls=($(VBoxManage showvminfo boot2docker-vm | grep NIC | grep hub | awk '{print "http://" $13 ":"  $17}' | sed 's/,//g'))
   for url in "${urls[@]}"
   do
      echo $url
   done
}

status=$(boot2docker status)
echo "status docker " $status
if [ "$status" == "running" ]; then
   #check if the hub is already running.
   eval $(boot2docker shellinit)
   running_containers=$(docker ps  | grep $_DOCKER_IMAGE | wc -l)
   if [ $running_containers -gt 0 ]; then
      echo "dockerized hub already running"
      printUrls
      exit
   fi
fi
