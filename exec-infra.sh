#!/bin/bash

#set -e

#tmpfile=$(mktemp)
tmpfile="$(pwd)/.temp.infra"
date=$(date "+%Y-%m-%d.%H-%M")

touch $tmpfile && printf "Temp file: $tmpfile\n"

destroy_docker_images(){
  docker stop $@
  docker rm -f $@
}

destroy_multipass_vms(){
  sudo multipass delete $@ || return 1
  sudo multipass purge
}


destroy(){
  mapfile -t DOCKER_CONTAINERS < <(grep "docker:" .temp.infra |  cut -d':' -f2) # awk -F ':' '{printf $2}'
  for i in ${DOCKER_CONTAINERS[@]}; do
    destroy_docker_images $i || { printf "[!] Error destroy container ($i)"; exit 1; }
  done
   

  mapfile -t VMS_LIST < <(grep "multipass:" .temp.infra |  cut -d':' -f2)
  for i in ${VMS_LIST[@]}; do
    destroy_multipass_vms $i || { printf "[!] Error destroy vm ($i)"; exit 1; }
  done
}

build(){
  printf "[+] Deploy infrastructure\n"
  ANSIBLE="ansible"
  HUB_HOST="server01"
  PEERS_HOST="node0"
  PEERS_NUM=2

  printf "[+] Create ansible node\n"
  printf '\ndocker:' >> $tmpfile; docker run -d \
  --name $ANSIBLE \
  --network host \
  -v "$(pwd)/docker/containers/ansible/ansible:/ansible" \
  -v "$(pwd)/docker/containers/ansible/ssh:/root/.ssh/" \
  -w /ansible \
  willhallonline/ansible:latest \
  sleep infinity 1>> $tmpfile 2>/dev/tty

  printf '\t[+] Create VM (HUB)'
  ./scripts/multipass-setup.sh single $HUB_HOST "4G" "20G" 2

  printf '\t[+] Create VMs (peers)'
  ./scripts/multipass-setup.sh multi $PEERS_HOST "4G" "20G" 2 3
}

wg-test(){
  docker build --no-cache -t wireguard-container docker/images/wireguard

  printf 'docker:' >> $tmpfile; docker run --name wireguard.$date \
    --cap-add=NET_ADMIN \
    --cap-add=SYS_MODULE \
    --net=host \
    --device /dev/net/tun \
    -v $(pwd)/wg0.conf:/etc/wireguard/wg0.conf \
    -d wireguard-container 1>> $tmpfile 2>/dev/tty
}


[[ $1 =~ (build|destroy) ]] && { eval $1; }