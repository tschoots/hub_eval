#!/bin/bash

free_pages=$(vm_stat | awk '/Pages free:/ {print $3}' | sed 's/\.//')
page_size_bytes=$(vm_stat | awk '/page size of/ {print $8}')

free_mem_mb=$(awk "BEGIN {printf \"%.0f\", $(($free_pages * $page_size_bytes))/1048576}")

max_mem=$(sysctl hw.memsize | awk '{print $2}')
max_mem=$(awk "BEGIN {printf \"%.0f\", $(($max_mem / 1048576))*0.75}")  # take 75% of total memory

mem=8192

# Set the container memory
mem_set_cmd="VBoxManage modifyvm boot2docker-vm --memory ${mem}"
echo $mem_set_cmd

echo $free_pages
echo $page_size_bytes
echo $free_mem_mb
