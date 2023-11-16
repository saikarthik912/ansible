#!/bin/bash

# Install the package from the repositories 

sudo dnf install haproxy -y

# Confirm that HAProxy is installed 

rpm -qi haproxy

# Backup copy of the configuration file 

sudo cp /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.bak

# Replace the haproxycfg with your config





#Configure Rsyslog  

#Access the Rsyslog configuration file. 

# Replace rsyslog.conf with your file /etc/rsyslog.conf







#Create an HAProxy configuration file 

# Replace haproxy.conf with your file in /etc/rsyslog.d/haproxy.conf 








# Set the following SELinux rule 

sudo setsebool -P haproxy_connect_any 1


# Restart and enable Rsyslog to effect the changes 

sudo systemctl restart rsyslog

sudo systemctl enable rsyslog

sudo systemctl start haproxy

sudo systemctl enable haproxy

sudo systemctl status haproxy

