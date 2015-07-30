#!/bin/bash


# determine the max memory by taking the minimum of 75% of total memory and the amount of free memory
free_pages=$(vm_stat | awk '/Pages free:/ {print $3}' | sed 's/\.//')
page_size_bytes=$(vm_stat | awk '/page size of/ {print $8}')
free_mem_mb=$(awk "BEGIN {printf \"%.0f\", $(($free_pages * $page_size_bytes))/1048576}")
echo "free_mem_mb : " $free_mem_mb

# check if the boot2docker-vm is running if it is running we have to add the memory to the free memory
boot2docker init
status=$(boot2docker status)
echo "status docker " $status
if [ "$status" == "running" ]; then
   vb_mem=$(VBoxManage showvminfo boot2docker-vm | awk '/Memory size:/ {print $3}' | sed 's/MB//')
   free_mem_mb=$(($free_mem_mb + $vb_mem))
fi
echo "free_mem_mb : " $free_mem_mb

max_mem=$(sysctl hw.memsize | awk '{print $2}')
max_mem=$(awk "BEGIN {printf \"%.0f\", $(($max_mem / 1048576))*0.75}")  # take 75% of total memory

echo $max_mem
if [ $free_mem_mb -lt $max_mem ];then
   max_mem=$free_mem_mb
fi

echo $max_mem
echo $free_pages
echo $page_size_bytes
echo $free_mem_mb
