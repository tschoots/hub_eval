#!/bin/bash

_REPO_DIR="/repos"

_HOME_DIR=$(eval echo "~$(whoami)")

echo $_HOME_DIR

cd $_REPO_DIR/rest-backend

if [ -d $_REPO_DIR/rest-backend ]; then
  echo "hallo22"
fi
if [ -d $_REPO_DIR ]; then
  echo "hallo"
fi

