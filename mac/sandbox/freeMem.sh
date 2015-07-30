#!/bin/bash


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

echo $max_mem
echo $free_pages
echo $page_size_bytes
echo $free_mem_mb
