#!/bin/bash


echo $UID
#[ "$UID" -eq 0 ] || exec sudo bash "$0" "$@"
if [[ "$UID" -gt 0 ]]; then
   echo "ports < 1024 need sudo permision : "
   exec sudo bash "$0" "$@"
fi
