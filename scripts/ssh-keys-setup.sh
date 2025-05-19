#!/bin/bash

SSH_KEY_PATH="docker/containers/ansible/ssh/id_rsa_ansible.pem.pub"
SSH_PRIVATE_KEY_PATH="docker/containers/ansible/ssh/id_rsa_ansible.pem"

[ ! command -v ssh-keygen &> /dev/null ] && {
    echo "ssh-keygen could not be found. Please install it first."
    exit 1
}

[[ -f $SSH_KEY_PATH && -f $SSH_PRIVATE_KEY_PATH && $1 != "--force" ]] || {
    printf "Las claves ya estan generadas\n"
    printf "SSH_PATH_PUB_KEY:$SSH_KEY_PATH\nSSH_PATH_PRIVATE_KEY:$SSH_PRIVATE_KEY_PATH"
    exit 0
}

printf '[+] Clean directory ssh keys\n'
rm -f docker/containers/ansible/ssh/id_rsa* &>/dev/null

printf '[+] Exec ssh-keygen\n'
ssh-keygen -t ed25519 -f $SSH_PATH_PRIVATE_KEY -N ""
printf "SSH_PATH_PUB_KEY:$SSH_KEY_PATH\nSSH_PATH_PRIVATE_KEY:$SSH_PRIVATE_KEY_PATH"

#[[ -f docker/image/ubuntu-ssh/authorized_keys ]] || {
#    cp ansible/ssh/id_rsa_ansible.pub docker/image/ubuntu-ssh/authorized_keys
#}