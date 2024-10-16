### `README.md`

markdown
# Firewall Management with UFW and Dynamic IP Whitelisting

This repository provides two main scripts:
1. **ufw_firewall.sh**: Manages the UFW (Uncomplicated Firewall) by whitelisting a set of hardcoded IPs and dynamic IPs fetched from a file (`ips.txt`).
2. **fetch_ip.sh**: Fetches the IP addresses from a remote GitHub repository and appends any new IPs to the `ips.txt` file.

Additionally, crontabs are provided to automate both tasks.

## 1. `ufw_firewall.sh` Script

This script configures UFW to:
- **Whitelist hardcoded IPs** specified in the script.
- **Whitelist dynamic IPs** from a file (`ips.txt`), which is updated by `fetch_ip.sh`.
- **Allow outgoing traffic** (for internet access) while **restricting all incoming traffic** except the whitelisted IPs.

### Script Explanation:

```bash
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
hardcoded_ips=("213.121.184.27" "213.121.184.30")
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
```

### Crontab for `ufw_firewall.sh`

This script should run periodically to ensure the firewall is updated with any new IPs added to `ips.txt`. To create a crontab that runs every 5 minutes, use the following:

```bash
*/5 * * * * /path/to/ufw_firewall.sh >> /path/to/firewall.log 2>&1
```

This ensures the firewall updates regularly and logs the output to `firewall.log`.

---

## 2. `fetch_ip.sh` Script

This script fetches IP addresses from a remote GitHub repository and appends them to the `ips.txt` file, ensuring that any new IPs are added.

### Script Explanation:

```bash
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
```

### Crontab for `fetch_ip.sh`

To ensure the script fetches new IPs every 5 minutes, add this crontab:

```bash
*/5 * * * * /path/to/fetch_ip.sh >> /path/to/fetch.log 2>&1
```

This will run the IP fetcher every 5 minutes and log the output to `fetch.log`.

---

## GitHub Repository Setup

The `ips.txt` file is hosted in this GitHub repository and is fetched by the `fetch_ip.sh` script. You can update this file directly from the GitHub GUI, and new IPs will automatically be fetched and whitelisted by the firewall.

### Steps:
1. Clone this repository or download the scripts.
2. Set up the crontabs for both `fetch_ip.sh` and `ufw_firewall.sh` as described above.
3. Add new IPs to the `ips.txt` file in GitHub, and they will be dynamically whitelisted by the firewall.
```

---

### Summary of Content:

- **`ufw_firewall.sh`**: A script to configure UFW with default rules and whitelist IPs.
- **`fetch_ip.sh`**: A script to fetch IP addresses from GitHub and update the `ips.txt` file.
- **Crontabs**: Automate both scripts to run every 5 minutes.
- **GitHub**: IP addresses are stored in `ips.txt` on GitHub, which is fetched by the scripts.
