#!/bin/bash

# Check if argument is assigned 
if [ -z "$1" ]; then
    echo "Usage: $0 <Base IP Address>"
    echo "Example: $0 192.168.1"
    read -p "Enter the base IP address (e.g., 192.168.1): " base_ip
else
    base_ip=$1
fi

# Scan IP-range
echo "Scanning IP range: $base_ip.1 - $base_ip.254"
for ip in $(seq 1 254); do
    ping -c 1 $base_ip.$ip | grep "64 bytes" | cut -d " " -f 4 | tr -d ":" &
done
wait
echo "Scan complete."
