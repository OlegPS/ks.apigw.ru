#!/usr/bin/env bash
set -e

# Disable swap
sudo systemctl mask --now swap.target
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Update
sudo dnf update -y

# Install additional packages
sudo dnf install -y ethtool iproute-tc socat nfs-utils

# Check sync time
#ntpq -p

# Enable ip_tables kernel module
sudo modprobe ip_tables
sudo sh -c 'echo "ip_tables" > /etc/modules-load.d/istio-ip_tables.conf'

# Enable firewall

# Configure sshd

# Install ClamAV
#dnf -y install clamav-server clamav-data clamav-update clamav-filesystem clamav clamav-scanner-systemd clamav-lib clamav-server-systemd
#sed -i 's@DatabaseMirror\s.*@DatabaseMirror https://packages.microsoft.com/clamav/@' /etc/freshclam.conf
#freshclam
#systemctl enable clamav-freshclam
#systemctl start clamav-freshclam

# Add GOST ciphers
#dnf install openssl-gost-engine
#openssl-switch-config gost

# SCAP
#dnf install openscap-scanner openscap-utils -y
