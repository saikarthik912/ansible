#!/bin/bash



folder_to_delete="/etc/letsencrypt"

# Check if the folder exists
if [ -d "$folder_to_delete" ]; then
    # Folder exists, so delete it and its contents
      sudo   rm -rf "$folder_to_delete"
    echo "Folder deleted successfully."
else
    echo "Folder does not exist."
fi


#sudo yum install epel-release -y

sudo dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm -y


sudo rpm -ql epel-release -y


sudo yum install certbot -y


sudo systemctl stop haproxy
 
sudo mkdir /etc/haproxy/certs



sudo certbot certonly --standalone --preferred-challenges http --http-01-port 80 --non-interactive      --agree-tos  -m  bhanu.karthik@passionbytes.io  LETSENCRYPT_CFG


sudo chmod -R go-rwx /etc/haproxy/certs

DOMAIN="LETSENCRYPT_DOMAIN" sudo -E bash -c 'cat /etc/letsencrypt/live/$DOMAIN/fullchain.pem /etc/letsencrypt/live/$DOMAIN/privkey.pem > /etc/haproxy/certs/$DOMAIN.pem'

#sudo systemctl start haproxy
