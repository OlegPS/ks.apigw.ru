#!/usr/bin/env bash
set -e

# Update
sudo dnf update -y

# Check sync time
#ntpq -p

# Enable firewall

# Configure sshd

# Install ClamAV
#dnf -y install clamav-server clamav-data clamav-update clamav-filesystem clamav clamav-scanner-systemd clamav-lib clamav-server-systemd
#sed -i 's@DatabaseMirror\s.*@DatabaseMirror https://packages.microsoft.com/clamav/@' /etc/freshclam.conf
#freshclam
#systemctl enable clamav-freshclam
#systemctl start clamav-freshclam

# SELinux
#dnf install selinux-policy

# Add GOST ciphers
#dnf install openssl-gost-engine
#openssl-switch-config gost

# SCAP
#dnf install openscap-scanner openscap-utils -y
