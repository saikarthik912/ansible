#!/bin/sh

# Prompt user for the number of IP addresses
echo -n "Enter the number of IP addresses to copy the SSH key to NOTE: This also includes your master: "
read num_ips

# Generate SSH key
echo "Generating SSH key..."
sudo echo -e "\n\n\n" | sudo ssh-keygen -t rsa

# Loop over IP addresses and copy the SSH key
for ((i=1; i<=num_ips; i++)); do
  echo -n "Enter IP address of the Master followed by the worker Nodes $i: "
  read ip_addr
  sudo ssh-copy-id -i ~/.ssh/id_rsa.pub $ip_addr
  sudo  echo $ip_addr >> hosts
done

echo "SSH key copied to $num_ips IP addresses! Successfully"



# Ansible Installation

#for Rhel8 and above use ansible-core packages
#sudo dnf install ansible-core

echo "Initiating Ansible Installation...."
sudo dnf install ansible -y
echo "SSH key copied to /etc/ansible/hosts file Successfully" 
sudo mv hosts /etc/ansible/
ansible --version
sudo ansible all -m ping

