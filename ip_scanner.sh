#!/bin/bash

# Function to validate an IP address
validate_ip() {
    local ip=$1
    local valid_regex="^([0-9]{1,3}\.){3}[0-9]{1,3}$"
    if [[ $ip =~ $valid_regex ]]; then
        for octet in $(echo $ip | tr "." " "); do
            if ((octet < 0 || octet > 255)); then
                return 1
            fi
        done
        return 0
    else
        return 1
    fi
}

# Function to calculate range from CIDR
cidr_to_range() {
    local cidr=$1
    local ip=${cidr%/*}
    local prefix=${cidr#*/}
    if ! validate_ip "$ip" || ! [[ $prefix =~ ^[0-9]+$ ]] || ((prefix < 0 || prefix > 32)); then
        echo "Invalid CIDR: $cidr"
        exit 1
    fi

    local mask=$((0xFFFFFFFF << (32 - prefix) & 0xFFFFFFFF))
    local base_ip=$(printf "%d\n" "$(echo $ip | awk -F'.' '{print ($1 * 256**3) + ($2 * 256**2) + ($3 * 256) + $4}')")
    start_ip=$((base_ip & mask))
    end_ip=$((start_ip | ~mask & 0xFFFFFFFF))
}

# Convert integer IP to dotted-decimal notation
int_to_ip() {
    local int_ip=$1
    echo "$((int_ip >> 24 & 0xFF)).$((int_ip >> 16 & 0xFF)).$((int_ip >> 8 & 0xFF)).$((int_ip & 0xFF))"
}

# Scan a single IP
scan_ip() {
    local ip=$1
    if ping -c 1 -W 0.5 "$ip" &>/dev/null; then
        echo "$ip is reachable"
        [[ -n $output_file ]] && echo "$ip" >>"$output_file"
    fi
}

# Main script
if [ -z "$1" ]; then
    echo "Usage: $0 <Base IP>, <IP Range>, or <CIDR>"
    echo "Examples:"
    echo "  $0 192.168.1"
    echo "  $0 192.168.1.1-192.168.1.254"
    echo "  $0 192.168.1.0/24"
    read -p "Enter the IP range or CIDR: " input_ip
else
    input_ip=$1
fi

# Determine input type
if [[ $input_ip =~ / ]]; then
    echo "CIDR notation detected: $input_ip"
    cidr_to_range "$input_ip"
elif [[ $input_ip =~ - ]]; then
    # IP range
    start_ip=$(printf "%d\n" "$(echo ${input_ip%-*} | awk -F'.' '{print ($1 * 256**3) + ($2 * 256**2) + ($3 * 256) + $4}')")
    end_ip=$(printf "%d\n" "$(echo ${input_ip#*-} | awk -F'.' '{print ($1 * 256**3) + ($2 * 256**2) + ($3 * 256) + $4}')")
elif validate_ip "$input_ip"; then
    # Base IP
    start_ip=$(printf "%d\n" "$(echo "$input_ip.1" | awk -F'.' '{print ($1 * 256**3) + ($2 * 256**2) + ($3 * 256) + $4}')")
    end_ip=$(printf "%d\n" "$(echo "$input_ip.254" | awk -F'.' '{print ($1 * 256**3) + ($2 * 256**2) + ($3 * 256) + $4}')")
else
    echo "Invalid input. Provide a valid Base IP, IP range, or CIDR."
    exit 1
fi

# Ask to save results
output_file=""
read -p "Do you want to save the results to a file? (y/n): " save_results
if [[ $save_results =~ ^[Yy]$ ]]; then
    output_file="scan_results_$(date +%Y%m%d_%H%M%S).txt"
    echo "Results will be saved to $output_file"
fi

# Set concurrency
max_concurrent=50
read -p "Enter max concurrent pings (default $max_concurrent): " user_max_concurrent
if [[ $user_max_concurrent =~ ^[0-9]+$ ]] && ((user_max_concurrent > 0)); then
    max_concurrent=$user_max_concurrent
fi

# Start scanning
echo "Scanning range: $(int_to_ip $start_ip) to $(int_to_ip $end_ip)"
echo "Starting scan at $(date +"%H:%M:%S")"
active_processes=0
for ((current_ip = start_ip; current_ip <= end_ip; current_ip++)); do
    ip=$(int_to_ip "$current_ip")
    scan_ip "$ip" &
    ((active_processes++))
    if ((active_processes >= max_concurrent)); then
        wait -n
        ((active_processes--))
    fi
done
wait
echo "Scan complete at $(date +"%H:%M:%S"). Results saved to $output_file."
