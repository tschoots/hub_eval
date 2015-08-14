#!/bin/bash

#constants
_HOME_DIR=$(eval echo "~$(whoami)")
_REPO_DIR="$_HOME_DIR/repos/hub"




# now the installer is at the following place
# $_REPO_DIR/rest-backend/appmgr/appmgr.hubinstall/build/distributions/appmgr.hubinstall-2.4.0-SNAPSHOT.zip
# look for the installer file

function getInstallerPath {
   declare -a installers=($(find ~/repos/hub/ -name "hubInstaller-*-amd64.zip" | grep -iv "client"))
   #declare -a installers=($(find ~/repos/hub/ -name "*.zip"))
   nr_installers=${#installers[@]}
   if [ $nr_installers -eq 1 ]; then
     installer_path=${installers[0]}
   elif [ $nr_installers -eq 0 ]; then
     echo "ERROR: no installer found"
     exit
   elif [ $nr_installers -gt 1 ]; then
     echo "ERROR: $nr_installers installers found"
     for inst in "${installers[@]}"
     do
       echo $inst
     done
     exit
   fi
   echo $installer_path
}

path=$(getInstallerPath)

echo $path

../createDockerImage.sh --installerPath=$path
