#!/bin/bash

set -e

#tmpfile=$(mktemp)
tmpfile="$(pwd)/.temp.infra"
date=$(date "+%Y-%m-%d.%H-%M")

touch $tmpfile && printf "Create temp file: $tmpfile\n"

docker build --no-cache -t wireguard-container docker/wireguard

[ $1 == "wg-test" ] && {
  printf '\ndocker:' >> $tmpfile
  docker run --name wireguard.$date \
    --cap-add=NET_ADMIN \
    --cap-add=SYS_MODULE \
    --net=host \
    --device /dev/net/tun \
    -v $(pwd)/wg0.conf:/etc/wireguard/wg0.conf \
    -d wireguard-container 1>> $tmpfile 2>/dev/tty
}

destroy_docker_images(){
  docker stop $@
  docker rm -f $@
}

[ $1 == "destroy" ] && {
  mapfile -t docker_containers < <(grep "docker:" .temp.infra |  cut -d':' -f2) # awk -F ':' '{printf $2}'
  destroy_docker_images ${docker_containers[@]}
}