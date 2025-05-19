#!/bin/bash
# This script sets up a multipass instance with the necessary configurations for monitoring.

# Check if multipass is installed
if ! command -v multipass &> /dev/null
then
    echo "Multipass could not be found. Please install it first."
    exit 1
fi

# Global
SSH_KEY_PATH="docker/containers/ansible/ssh/id_rsa_ansible.pem.pub"
SSH_PRIVATE_KEY_PATH="docker/containers/ansible/ssh/id_rsa_ansible.pem"

# Create a server instance
SERVER_NAME="monitoring-server"
SERVER_MEMORY="4G"
SERVER_DISK="20G"
SERVER_CPUS=2

# Launch the server instance
sudo multipass launch --name "$SERVER_NAME" --cpus "$SERVER_CPUS" --memory "$SERVER_MEMORY" --disk "$SERVER_DISK"

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

# Create a multipass instance
NUM_INSTANCES=3
INSTANCE_NAME="node"

for i in $(seq 1 $NUM_INSTANCES); do
    sudo multipass launch --name "$INSTANCE_NAME-$i" --cpus 1 --memory 2G --disk 20G
done

# Install and enable SSH server
for i in $(seq 1 $NUM_INSTANCES); do
    sudo multipass exec "$INSTANCE_NAME-$i" -- sudo apt-get update
    sudo multipass exec "$INSTANCE_NAME-$i" -- sudo apt-get install -y openssh-server
    sudo multipass exec "$INSTANCE_NAME-$i" -- sudo bash -c "echo $(cat $SSH_KEY_PATH) >> /home/ubuntu/.ssh/authorized_keys"
    sudo multipass exec "$INSTANCE_NAME-$i" -- sudo systemctl enable ssh
    sudo multipass exec "$INSTANCE_NAME-$i" -- sudo systemctl start ssh
done

echo "Multipass setup completed successfully."

# Display connection information
echo "You can now SSH into the instances using the following command:"
for i in $(seq 1 $NUM_INSTANCES); do
    IP_ADDRESS=$(sudo multipass info "$INSTANCE_NAME-$i" | grep "IPv4" | awk '{print $2}')
    echo "ssh -i $SSH_PRIVATE_KEY_PATH ubuntu@$IP_ADDRESS"
done
