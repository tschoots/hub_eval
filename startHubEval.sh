#!/bin/bash

: ${HOSTNAME?}

STARTUP_CMD="docker run -t -i   -h hubeval.blackducksoftware.com -p 4181:4181 -p 80:8080 -p 7081:7081 -p 55436:55436 -p 8009:8009 -p 8993:8993 -p 8909:8909 $1  /opt/blackduck/maiastra/start.sh"



echo $STARTUP_CMD

$STARTUP_CMD
