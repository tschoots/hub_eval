#!/bin/bash

_MIN_MEM=8192
_DEFAULT_PORT=80


port=$_DEFAULT_PORT

max_mem=$(sysctl hw.memsize | awk '{print $2}')
max_mem=$(awk "BEGIN {printf \"%.0f\", $(($max_mem / 1048576))*0.75}")  # take 75% of total memory
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
      mem=$(memInput)
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
   echo "default --port=80 --memory=<75% of total memory, minumum = $_MIN_MEM >"
   exit
   ;;
   *)
      # unknown option
   ;;
esac
done

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
VBoxManage modifyvm boot2docker-vm --memory $mem

# route port 80 and 7081 to the host port
VBoxManage modifyvm "boot2docker-vm" --natpf1 "tcp-port$(port),tcp,,$(port),,$(port)"
VBoxManage modifyvm "boot2docker-vm" --natpf1 "tcp-port7081,tcp,,7081,,7081"

#initialize the shell so docker commands can be performed.
eval $(boot2docker shellinit)
