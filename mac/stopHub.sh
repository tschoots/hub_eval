#!/bin/bash
_DOCKER_IMAGE="docker.io/blackduckhub/eval:latest"

# get the environment in place
eval $(boot2docker shellinit)

# get the running container id of the hub container
container_id=$(docker ps | grep $_DOCKER_IMAGE | awk '{print $1;}')

echo $container_id
if [ -n "$container_id" ]; then
    # now we know the container  id  stop it
    docker stop  $container_id
else
    printf "no container from image : %s is running.\n" "$_DOCKER_IMAGE"
fi



