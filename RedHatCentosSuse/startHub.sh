#!/bin/bash

#remove older containers
docker rm $(docker ps -a -q)

: ${HOSTNAME?}

#STARTUP_CMD="docker run -t -i  -h $HOSTNAME   -p 4181:4181 -p 80:8080 -p 7081:7081 -p 55436:55436 -p 8009:8009 -p 8993:8993 -p 8909:8909 eval3:0.2  /opt/blackduck/maiastra/start.sh"
#STARTUP_CMD="docker run -t -i  -h $HOSTNAME   -p 4181:4181 -p 80:8080 -p 7081:7081 -p 55436:55436 -p 8009:8009 -p 8993:8993 -p 8909:8909 eval3:0.2  /bin/bash"
#STARTUP_CMD="docker run -t -i  -h $HOSTNAME   -p 4181:4181 -p 80:8080 -p 7081:7081 -p 55436:55436 -p 8009:8009 -p 8993:8993 -p 8909:8909 docker.io/blackduckhub/eval  /opt/blackduck/maiastra/start.sh"
STARTUP_CMD="docker run -t -i  -h $HOSTNAME   -p 4181:4181 -p 80:8080 -p 7081:7081 -p 55436:55436 -p 8009:8009 -p 8993:8993 -p 8909:8909 docker.io/blackduckhub/eval  /bin/bash"


echo $STARTUP_CMD

$STARTUP_CMD
