#!/bin/bash

#constants
_HOME_DIR=$(eval echo "~$(whoami)")
_REPO_DIR="$_HOME_DIR/repos/hub"


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
   git checkout -b dev/HUB-3111 origin/dev/HUB-3111
fi


cd $_REPO_DIR/rest-backend
./gradlew -Dappmgr.artifactory.url=http://artifactory.blackducksoftware.com:8081/artifactory/bds-deployment-test/ build uploadArchives -x test --rerun-tasks

#cd $_REPO_DIR/appmgr
#./gradlew -Dappmgr.artifactory.url=http://artifactory.blackducksoftware.com:8081/artifactory/bds-deployment-test/ build uploadArchives -x test --rerun-tasks
