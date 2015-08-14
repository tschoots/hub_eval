#!/bin/bash

#constants
_HOME_DIR=$(eval echo "~$(whoami)")
_DOCKER_BUILD_DIR="$_HOME_DIR/tmp/DockerBuild"       # directory where the Dockerfile will be created
_HUB_INSTALLER_DIR="$_DOCKER_BUILD_DIR/hub_installer"  # in this directory the installer will be unpacked




#######################################
#
#        MAIN
#
######################################

#get iput parameters
for i in $@
do
case $i in 
  -i=*|--installerPath=*)
    _INSTALLER_PATH="${i#*=}"
  ;;
  --help)
    echo "usage : $0 -i|--installerPath <path to installer>"
  ;;
  *)
    echo "no parameters , do $0 --help for options"
  ;;
esac
done


# clean directories
if  [ -d $_DOCKER_BUILD_DIR ]; then
  rm -rf $_DOCKER_BUILD_DIR
fi
mkdir -p $_HUB_INSTALLER_DIR
unzip $_INSTALLER_PATH -d  $_HUB_INSTALLER_DIR
