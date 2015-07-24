#!/bin/bash

_DOCKER_IMAGE="docker.io/blackduckhub/eval:latest"

# check available memory
free_mem_in_gb=$(free -g | grep "Mem" | awk '{print $4;}')
printf "%sGb free memory.\n" "$free_mem_in_gb"
if [ "${free_mem_in_gb:-0}" -lt 8 ];then
    echo "WARNING minimum of 8Gb required."
fi

# check if there is a ready a container running
nr_containers=$(docker ps  | grep $_DOCKER_IMAGE | wc -l)
if [ $nr_containers -gt 0 ]; then
    echo "the hub container is already running"
    exit
fi


#See if the image was already started by looking for the container

nr_containers=$(docker ps -a | grep $_DOCKER_IMAGE | wc -l)

if [ $nr_containers -gt 1 ]; then
    # several containers cleanup
    echo "several containers cleaning up"
    containers=($(docker ps -a | grep $_DOCKER_IMAGE | awk '{print $1;}'))
    for container in "${containers[@]}"; do
       echo ${container}
       # delete the older containers
       containers_to_delete=($(docker ps -a --before=${container} | grep Exited |  grep $_DOCKER_IMAGE |  awk '{print $1;}' ))
       for del_con in "${containers_to_delete[@]}";do
          printf "\tdelete container : %s\n" "${del_con}"
          docker rm $del_con
       done
    done
fi

nr_containers=$(docker ps -a | grep $_DOCKER_IMAGE | wc -l)
if [ $nr_containers = 1 ]; then
    # dockerized hub started and stopped start the container again.
    container_id=$(docker ps -a | grep $_DOCKER_IMAGE | awk '{print $1;}')
    printf "startting container : %s\n" "$container_id"
    docker start $container_id
fi

if [ $nr_containers = 0 ]; then
    #no containers started so start the image
    echo "first time image is started"
    STARTUP_CMD="docker run -t -i  -h $HOSTNAME   -p 4181:4181 -p 80:8080 -p 7081:7081 -p 55436:55436 -p 8009:8009 -p 8993:8993 -p 8909:8909 $_DOCKER_IMAGE  /opt/blackduck/maiastra/start.sh"
    echo $STARTUP_CMD
    $STARTUP_CMD
fi
