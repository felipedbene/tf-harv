#!/bin/bash

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root."
    exit 1
fi

echo "Step 1: Ensuring keyrings directory exists..."
mkdir -p /etc/apt/keyrings

echo "Step 2: Downloading public key..."
curl -fsSL https://packages.broadcom.com/artifactory/api/security/keypair/SaltProjectKey/public | tee /etc/apt/keyrings/salt-archive-keyring.pgp

echo "Step 3: Creating apt repo target configuration..."
curl -fsSL https://github.com/saltstack/salt-install-guide/releases/latest/download/salt.sources | tee /etc/apt/sources.list.d/salt.sources

echo "Step 4: Setting up APT pinning for Salt packages..."
echo 'Package: salt-*
Pin: version 3006.*
Pin-Priority: 1001' | tee /etc/apt/preferences.d/salt-pin-1001

echo "Step 5: Updating package lists..."
apt update

echo "Step 6: Installing Salt Master..."
apt-get install -y salt-master

echo "Step 7: Holding the Salt Master package..."
apt-mark hold salt-master

echo "Step 8: Enabling and starting the Salt master service..."
systemctl enable salt-master
systemctl start salt-master

echo "Step 9: Checking Salt master service status..."
systemctl status salt-master

echo "Step 11: Restarting the Salt master service..."
systemctl restart salt-master

echo "Step 12: Checking Salt master service status..."
systemctl status salt-master

echo "Salt master setup is complete."
