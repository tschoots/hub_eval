#!/bin/bash

#constants
_HOME_DIR=$(eval echo "~$(whoami)")
_REPO_DIR="$_HOME_DIR/repos/hub"


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

##########################################################################
# 
#                     MAIN
#
#########################################################################
# check if directories exist
if [ -d $_REPO_DIR/appmgr ]; then
   cd $_REPO_DIR/appmgr
   git pull 
else
   mkdir -p $_REPO_DIR 
   cd $_REPO_DIR
   git clone http://stash.blackducksoftware.com/scm/commoncomp/appmgr.git
   cd $_REPO_DIR/appmgr
   git checkout -b dev/HUB-3277 origin/dev/HUB-3277
fi

if [ -d $_REPO_DIR/rest-backend ]; then
   cd $_REPO_DIR/rest-backend
   git pull
else
   cd $_REPO_DIR
   git clone http://tschoots@stash.blackducksoftware.com/scm/hub/rest-backend.git
   cd $_REPO_DIR/rest-backend
   #git checkout -b dev/HUB-3111 origin/dev/HUB-3111
   #git checkout -b dev/HUB-3111_2_3_x origin/dev/HUB-3111_2_3_x
   git checkout -b release/MM_2_3_x origin/release/MM_2_3_x
fi

#rm -rf $_HOME_DIR/.m2
rm -rf $_HOME_DIR/.m2/repository/com/blackducksoftware/hub/scan.cli/2.4.0-SNAPSHOT
rm -rf $_HOME_DIR/.m2/repository/com/blackducksoftware/hub/job.standalone/2.4.0-SNAPSHOT
rm -rf $_HOME_DIR/.gradle/caches/modules-2/files-2.1/com.oracle.java/jre/1.7.0_80/356128907fb5c97c22724fc043c8a6195cde4d8
rm -rf $_HOME_DIR//repos/hub/rest-backend/appmgr/appmgr.hublayout/build/tmp/expandedArchives/jre-1.7.0_80-linux-x64.zip_bx30hrcau7ywc8tgsbx7li36v


cd $_REPO_DIR/rest-backend
./gradlew -Dappmgr.artifactory.url=http://artifactory.blackducksoftware.com:8081/artifactory/bds-deployment-test/ build uploadArchives -x test --rerun-tasks

cd $_REPO_DIR/appmgr
./gradlew -Dappmgr.artifactory.url=http://artifactory.blackducksoftware.com:8081/artifactory/bds-deployment-test/ build uploadArchives -x test --rerun-tasks

rm -rf $_HOME_DIR/.gradle/caches/modules-2/files-2.1/com.oracle.java/jre/1.7.0_80/356128907fb5c97c22724fc043c8a6195cde4d8/jre-1.7.0_80-linux-x64.zip



cd $_REPO_DIR/rest-backend
./gradlew -Dappmgr.artifactory.url=http://artifactory.blackducksoftware.com:8081/artifactory/bds-deployment-test/ build uploadArchives -x test --rerun-tasks -DuseLocalRepo


cd $_REPO_DIR/rest-backend
./gradlew -PuseLocalRepo -Dappmgr.artifactory.url=http://artifactory.blackducksoftware.com:8081/artifactory/bds-deployment-test/ -c ./appmgr.settings.gradle build uploadArchives -x test -x :appmgr:appmgr.hubinstall.client:fatJar --rerun-tasks


# find the installer
installerPath=$(getInstallerPath)
#./createDockerImage.sh $installerPath
