#!/bin/bash

_MIN_MEM=81920

# get the input parameters
for i in $@
do
case $i in
   -m=*|--memory=*)
   memInput="${i#*=}"
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

echo $memInput
echo $port
echo $0
