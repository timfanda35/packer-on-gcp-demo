#!/bin/bash

# Disable SELinux
sudo sed -i 's/^SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
sudo setenforce 0

# Read/Write user
sudo groupadd logrw
sudo useradd -M -s /sbin/nologin logexporter
sudo usermod -G logrw logexporter
sudo usermod -d /smb logexporter

# Read only user
sudo groupadd logr
sudo useradd -M -s /sbin/nologin logviewer
sudo usermod -G logr logviewer
sudo usermod -d /smb logviewer

# Create directory
sudo mkdir -p /logs/smb
sudo chown -R logexporter:logrw /logs/smb
sudo chmod 2754 /logs/smb
sudo setfacl -m g:logr:rx /logs/smb

# Update sshd config
sudo sed -i 's/^PasswordAuthentication/#PasswordAuthentication/' /etc/ssh/sshd_config
sudo sed -i 's/^Subsystem/#Subsystem/' /etc/ssh/sshd_config

cat << EOF | sudo tee -a /etc/ssh/sshd_config

Subsystem sftp internal-sftp

Match Group logrw
        PasswordAuthentication yes
        ChrootDirectory /logs
        ForceCommand internal-sftp
        AllowTcpForwarding no
        X11Forwarding no
Match Group logr
        PasswordAuthentication yes
        ChrootDirectory /logs
        ForceCommand internal-sftp
        AllowTcpForwarding no
        X11Forwarding no

EOF
