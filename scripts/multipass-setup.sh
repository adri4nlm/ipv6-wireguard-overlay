#!/bin/bash
# This script sets up a multipass instance with the necessary configurations for monitoring.

# Global
tmpfile="$(pwd)/.temp.infra"
SSH_KEY_PATH="docker/containers/ansible/ssh/id_rsa_ansible.pem.pub"
SSH_PRIVATE_KEY_PATH="docker/containers/ansible/ssh/id_rsa_ansible.pem"

# Check if multipass is installed
if ! command -v multipass &> /dev/null
then
    echo "Multipass could not be found. Please install it first."
    exit 1
fi

deploy_vm(){
    SERVER_NAME=$1
    SERVER_MEMORY=$2
    SERVER_DISK=$3
    SERVER_CPUS=$4

    # Launch the server instance
    sudo multipass launch --name "$SERVER_NAME" --cpus "$SERVER_CPUS" --memory "$SERVER_MEMORY" --disk "$SERVER_DISK" && {
        printf "\nmultipass:$SERVER_NAME" >> $tmpfile
    }

    # Install and enable SSH server
    sudo multipass exec "$SERVER_NAME" -- sudo apt-get update
    sudo multipass exec "$SERVER_NAME" -- sudo apt-get install -y openssh-server
    sudo multipass exec "$SERVER_NAME" -- sudo bash -c "echo $(cat $SSH_KEY_PATH) >> /home/ubuntu/.ssh/authorized_keys"
    sudo multipass exec "$SERVER_NAME" -- sudo systemctl enable ssh
    sudo multipass exec "$SERVER_NAME" -- sudo systemctl start ssh

    # Display server instance information
    echo "You can now SSH into the server instance using the following command:"
    IP_ADDRESS=$(sudo multipass info "$SERVER_NAME" | grep "IPv4" | awk '{print $2}')
    echo "ssh -i $SSH_PRIVATE_KEY_PATH ubuntu@$IP_ADDRESS"
}

[ $1 == "single" ] && { deploy_vm $2 $3 $4 $5; }

[ $1 == "multi" ] && {
    for i in $(seq 1 $6); do
        deploy_vm "$2$i" $3 $4 $5
    done
}
