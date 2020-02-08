#!/bin/bash

# Read/Write user
sudo groupadd logrw
sudo useradd -M -s /sbin/nologin logexporter
sudo usermod -G logrw logexporter

# Read only user
sudo groupadd logr
sudo useradd -M -s /sbin/nologin logviewer
sudo usermod -G logr logviewer

# Create directory
sudo mkdir -p /logs/smb
sudo chmod 2754 /logs/smb
sudo chown -R logexporter:logrw /logs/smb
sudo setfacl -m g:logr:rx /logs/smb

# Update sshd config
sudo sed -i 's/^PasswordAuthentication/#PasswordAuthentication/' /etc/ssh/sshd_config
sudo sed -i 's/^Subsystem/#Subsystem/' /etc/ssh/sshd_config

cat << EOF | sudo tee -a /etc/ssh/sshd_config
PasswordAuthentication yes

Subsystem sftp internal-sftp

Match Group logrw
        ChrootDirectory /logs
        ForceCommand internal-sftp -d smb
Match Group logr
        ChrootDirectory /logs
        ForceCommand internal-sftp -d smb
EOF

sudo service sshd restart
