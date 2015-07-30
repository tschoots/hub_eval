#!/bin/bash

# this is a start script for mac to start the BlackDuck hub in a docker container.
# it assumes boot2docker is already installed.
# minumum requirement is 8 gb of ram wich will be allocated in the boot2docker-vm

_DOCKER_IMAGE="docker.io/blackduckhub/eval:latest"
_MIN_MEM=8192
_DEFAULT_PORT=8080  # the default port on the mac host can be manipulated with --port= during startup
_HUB_PORT=5555      # the port that will be exposed on the boot2docker-vm and connected to port 8080 in the hub docker container , can't manipulate


function printUrls {
   echo  -e "\033[5m \033[4m \033[1murls connect to the dockerized hub : \033[0m"
   declare -a ports=($(VBoxManage showvminfo boot2docker-vm | grep NIC | grep hub | awk '{print   $17}' | sed 's/,//g' | uniq))
   for port in "${ports[@]}"
   do
      echo "http://"${HOSTNAME}":"$port
   done
   declare -a urls=($(VBoxManage showvminfo boot2docker-vm | grep NIC | grep hub | awk '{print "http://" $13 ":"  $17}' | sed 's/,//g'))
   for url in "${urls[@]}"
   do
      echo $url
   done
}

function checkHubRunning {
   # before doing anything see if dockerized container is already running.
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
}




port=$_DEFAULT_PORT

# determine the max memory by taking the minimum of 75% of total memory and the amount of free memory
free_pages=$(vm_stat | awk '/Pages free:/ {print $3}' | sed 's/\.//')
page_size_bytes=$(vm_stat | awk '/page size of/ {print $8}')
free_mem_mb=$(awk "BEGIN {printf \"%.0f\", $(($free_pages * $page_size_bytes))/1048576}")

max_mem=$(sysctl hw.memsize | awk '{print $2}')
max_mem=$(awk "BEGIN {printf \"%.0f\", $(($max_mem / 1048576))*0.75}")  # take 75% of total memory

echo $max_mem
if [ $free_mem_mb -lt $max_mem ];then
   max_mem=$free_mem_mb
fi

cpus=$(sysctl kern.aioprocmax | awk '{print $2}')
max_cpus=$(awk "BEGIN {printf \"%.0f\", $(($cpus))*0.5}")  # take 75% of total memory


if [ $max_mem -lt $_MIN_MEM ]; then
   echo "minumum memory required : " $_MIN_MEM
   echo "75% of total memory     : " $max_mem
   echo "ERROR not enough memory"
   exit
fi
#echo "Allocating 75% of memory : " $max_mem
#echo "Allocating 50% of cpus   : " $max_cpus

# get the input parameters
for i in $@
do
case $i in
   -m=*|--memory=*)
   memInput="${i#*=}"
   if [ $memInput -lt $max_mem ]; then
      mem=$memInput
   else
      echo "ERROR 75% of total memory : $max_mem, this is less than input $memInput mb"
      exit
   fi
   ;;
   -p=*|--port=*)
   port="${i#*=}"
   ;;
   --help)
   echo "usage : $0 [-m|--memory=<memory size in mb>] [-p|--port=<port nr>] [--help]"
   echo "default --port=8080 --memory=<75% of total memory, minumum = $_MIN_MEM >"
   exit
   ;;
   *)
      # unknown option
   ;;
esac
done

checkHubRunning

# check port if we have to start with sudo rights
   if [[ "$port" -lt 1024 ]]; then
      # if ports less then 1024 need sudo permisssion.
      if [[ "$UID" -gt 0 ]]; then
         echo "ports < 1024 need sudo permision : " 
         exec sudo bash "$0" "$@"
      fi
   fi

# check if the boot2docker-vm is running it has to be stopped before we start configuration
boot2docker init
status=$(boot2docker status)
echo "status docker " $status
if [ "$status" == "running" ]; then
   echo "stop boot2docker to configure boot2docker-vm"
   $(boot2docker stop)
fi

# Set the container memory
mem_set_cmd="VBoxManage modifyvm boot2docker-vm --memory ${mem}"
echo $mem_set_cmd
`$mem_set_cmd`

## now start working to the port forwarding.

#find all the boot2docker port forwarding routes and delete them
declare -a routes_to_remove=($(VBoxManage showvminfo boot2docker-vm | grep NIC | grep hub | awk '{print $6}' | sed 's/,//g'))
for r in "${routes_to_remove[@]}"
do
  dr1="VBoxManage modifyvm boot2docker-vm --natpf1 delete ${r}"
  echo $dr1
  `$dr1`
done

# here the routes for all active ip addresses are set, notice ip addresses are found dynamically
declare -a ipAddresses=($(netstat -p tcp | grep "ESTABLISHED" | awk '{print $4}' | sed 's/\./ /g' | awk '{print $1 "." $2 "." $3 "." $4}' | uniq) '127.0.0.1')
i=0
for ip in "${ipAddresses[@]}"
do
  # make the port forwarding rules to be set in boot2docker-vm
  r1="VBoxManage modifyvm boot2docker-vm --natpf1 hub${i},tcp,${ip},${port},,${_HUB_PORT}"
  r2="VBoxManage modifyvm boot2docker-vm --natpf1 hub_console${i},tcp,${ip},7081,,7081"
  echo $r1
  `$r1`
  echo $r2
  `$r2`
  i+=1
done


# print the urls to use to connect to the hub
printUrls


#start the boot2docker-vm
boot2docker up

#initialize the shell so docker commands can be performed.
eval $(boot2docker shellinit)


# check if there is a ready a container running
nr_containers=$(docker ps  | grep $_DOCKER_IMAGE | wc -l)
if [ $nr_containers -gt 0 ]; then
    echo "the hub container is already running"
    exit
fi

#See if the image was already started by looking for the container

nr_containers=$(docker ps -a | grep $_DOCKER_IMAGE | wc -l)

if [ $nr_containers -gt 1 ]; then
    # several containers cleanup
    echo "several containers cleaning up"
    containers=($(docker ps -a | grep $_DOCKER_IMAGE | awk '{print $1;}'))
    for container in "${containers[@]}"; do
       echo ${container}
       # delete the older containers
       containers_to_delete=($(docker ps -a --before=${container} | grep Exited |  grep $_DOCKER_IMAGE |  awk '{print $1;}' ))
       for del_con in "${containers_to_delete[@]}";do
          printf "\tdelete container : %s\n" "${del_con}"
          docker rm $del_con
       done
    done
fi

if [ $nr_containers = 1 ]; then
    # dockerized hub started and stopped start the container again.
    container_id=$(docker ps -a | grep $_DOCKER_IMAGE | awk '{print $1;}')
    printf "startting container : %s\n" "$container_id"
    docker start $container_id
fi

if [ $nr_containers = 0 ]; then
    #no containers started so start the image
    echo "first time image is started"
    STARTUP_CMD="docker run -t -i  -h $HOSTNAME   -p 4181:4181 -p $_HUB_PORT:8080 -p 7081:7081 -p 55436:55436 -p 8009:8009 -p 8993:8993 -p 8909:8909 $_DOCKER_IMAGE  /opt/blackduck/maiastra/start.sh -d"
    echo $STARTUP_CMD
    $STARTUP_CMD
fi

printUrls
