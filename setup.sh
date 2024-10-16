#!/bin/bash

# Move the scripts to /root directory
echo "Starting Setup..."

echo "Moving ufw_firewall.sh and fetch_ip.sh to /root directory..."
mv ufw_firewall.sh /root/
mv fetch_ip.sh /root/

# Make the scripts executable
chmod +x /root/ufw_firewall.sh
chmod +x /root/fetch_ip.sh

# Set up cron jobs for fetch_ip.sh and ufw_firewall.sh
echo "Setting up cron jobs..."

# Remove any existing cron jobs related to fetch_ip.sh and ufw_firewall.sh
crontab -l | grep -v "fetch_ip.sh" | grep -v "ufw_firewall.sh" | crontab -

# Add cron job for fetch_ip.sh every 5 minutes
(crontab -l; echo "*/5 * * * * /root/fetch_ip.sh") | crontab -

# Add cron job for ufw_firewall.sh every 5 minutes
(crontab -l; echo "*/5 * * * * /root/ufw_firewall.sh") | crontab -

echo "Cron jobs set up successfully!"

echo "Firewall set up successfully!"
