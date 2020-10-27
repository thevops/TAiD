#!/bin/bash
# this script should be run by Makefile task

function docker_cmd() {
    name="$1"
    ip="$2"
    echo "Starting... $name - $ip"
    docker run -d --privileged --rm -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
            --name "${DOCKER_CONTAINERS_PREFIX}${name}" \
            --net "$DOCKER_NETWORK_NAME" \
            --ip "$ip" \
            "$DOCKER_IMAGE"
    # start SSH service
    docker exec "${DOCKER_CONTAINERS_PREFIX}${name}" systemctl start ssh
}


# create network
docker network create --subnet=${DOCKER_NETWORK_SUBNET}/24 "$DOCKER_NETWORK_NAME"


#! ---   EDIT HERE   --- !#

# front01
docker_cmd front-01 172.20.0.11

# front02
docker_cmd front-02 172.20.0.12

# app01
docker_cmd app-01 172.20.0.21

# app02
docker_cmd app-02 172.20.0.22

# backend01
docker_cmd backend-01 172.20.0.31

# backend02
docker_cmd backend-02 172.20.0.32

# backend03
docker_cmd backend-03 172.20.0.33

