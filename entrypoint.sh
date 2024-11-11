#!/bin/bash

# Default values
DURATION=${UPNP_DURATION:-86400}            # 24 hours in seconds
REFRESH_INTERVAL=$((DURATION * 80 / 100))   # Refresh at 80% of duration
DEFAULT_PORTS='[]'                          # Empty array as default

# Function to get local IP address
get_local_ip() {
    # First try to get it from upnpc -l
    local ip=$(upnpc -l 2>&1 | grep "Local LAN ip address" | cut -d':' -f2 | tr -d ' ')
    
    if [ -z "$ip" ]; then
        # Fallback method using ip command
        ip=$(ip route get 1 | awk '{print $(NF-2);exit}')
    fi
    
    echo "$ip"
}

# Function to validate JSON array
validate_ports() {
    if ! echo "$1" | jq empty; then
        echo "Error: PORTS environment variable must be a valid JSON array"
        exit 1
    fi
}

# Function to add a single port mapping
add_port_mapping() {
    local port=$1
    local protocol=$2
    local local_ip=$3
    
    echo "Adding mapping for port $port/$protocol..."
    upnpc -a "$local_ip" "$port" "$port" "$protocol" "$DURATION"
    local status=$?
    
    if [ $status -eq 0 ]; then
        echo "Successfully mapped port $port/$protocol"
    else
        echo "Failed to map port $port/$protocol"
    fi
    
    return $status
}

# Function to remove a single port mapping
remove_port_mapping() {
    local port=$1
    local protocol=$2
    
    echo "Removing mapping for port $port/$protocol..."
    upnpc -d "$port" "$protocol"
}

# Function to add all port mappings
add_port_mappings() {
    local ports_json=${PORTS:-$DEFAULT_PORTS}
    validate_ports "$ports_json"
    
    echo "Adding/Refreshing port mappings..."
    
    # Get local IP once
    local local_ip=$(get_local_ip)
    echo "Using local IP address: $local_ip"

    # Check if local IP is empty
    if [ -z "$local_ip" ]; then
        echo "Error: Failed to get local IP address"
        exit 1
    fi
    
    # Iterate through the JSON array
    echo "$ports_json" | jq -r '.[] | "\(.port) \(.protocol)"' | while read -r port protocol; do
        add_port_mapping "$port" "$protocol" "$local_ip"
    done
    
    # List current mappings
    echo "Current port mappings:"
    upnpc -l
}

# Function to remove all port mappings
remove_port_mappings() {
    local ports_json=${PORTS:-$DEFAULT_PORTS}
    
    echo "Removing all port mappings..."
    
    # Iterate through the JSON array
    echo "$ports_json" | jq -r '.[] | "\(.port) \(.protocol)"' | while read -r port protocol; do
        remove_port_mapping "$port" "$protocol"
    done
}

# Initial delay to ensure network is ready
sleep 5

# Trap SIGTERM and SIGINT
trap "remove_port_mappings; exit 0" TERM INT

# Main loop
while true; do
    add_port_mappings
    sleep "$REFRESH_INTERVAL"
done