#!/bin/bash

# Enable UFW if not already enabled, force confirmation with --force
if ! sudo ufw status | grep -q "Status: active"; then
    echo "Enabling UFW..."
    sudo ufw --force enable
fi

# Set default policies to deny all incoming traffic and allow all outgoing
echo "Setting UFW default policies..."
sudo ufw --force default deny incoming
sudo ufw --force default allow outgoing

# Fetch IPs from ips.txt
echo "Fetching IPs from ips.txt..."
if [ ! -f ips.txt ]; then
    echo "Error: ips.txt file not found!"
    exit 1
fi

# Whitelist hardcoded IPs
hardcoded_ips=("213.121.184.27" "213.121.184.30" "103.217.176.48")
for ip in "${hardcoded_ips[@]}"; do
    echo "Whitelisting hardcoded IP: $ip"
    sudo ufw allow from "$ip"
done

# Whitelist dynamic IPs from ips.txt
echo "Whitelisting dynamic IPs from ips.txt..."
while IFS= read -r ip; do
    if [[ -n "$ip" ]]; then
        echo "Whitelisting IP: $ip"
        sudo ufw allow from "$ip"
    fi
done < ips.txt

# Ensure internet access is allowed (outgoing traffic)
echo "Allowing outgoing internet traffic..."
sudo ufw allow out 80/tcp   # Allow HTTP
sudo ufw allow out 443/tcp  # Allow HTTPS

# Deny all other incoming traffic
echo "Denying all other incoming traffic..."
sudo ufw deny incoming

# Reload UFW to apply changes
echo "Reloading UFW rules..."
sudo ufw reload

# Display UFW status
echo "Current UFW rules:"
sudo ufw status verbose