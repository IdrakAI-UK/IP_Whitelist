#!/bin/bash

# Define the URL to fetch the file from the GitHub repository
GITHUB_URL="https://raw.githubusercontent.com/IdrakAI-UK/IP_Whitelist/main/ips.txt"

# Fetch the IPs from GitHub
echo "Fetching IPs from GitHub..."
curl -s "$GITHUB_URL" -o temp_ips.txt

# Check if file exists and has content
if [[ -s temp_ips.txt ]]; then
    echo "Appending new IPs to ips.txt..."
    while IFS= read -r ip; do
        if ! grep -q "$ip" ips.txt; then
            echo "$ip" >> ips.txt
            echo "New IP added: $ip"
        fi
    done < temp_ips.txt
    rm temp_ips.txt
else
    echo "Failed to fetch IPs or no new IPs found."
fi