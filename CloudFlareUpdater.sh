#!/bin/bash

CONFIG_FILE="$HOME/.cloudflare_config"

# Function to load configuration
load_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        source "$CONFIG_FILE"
        # After loading configuration, directly check and update the DNS record
        update_if_necessary
    else
        echo "No configuration file found, initializing setup."
        setup_config
    fi
}

# Function to set up initial configuration and DNS record
setup_config() {
    read -p "Enter your Cloudflare API Key: " API_KEY
    read -p "Enter your Cloudflare Email Address: " EMAIL
    read -p "Enter your Cloudflare Zone ID: " ZONE_ID
    read -p "Enter the DNS Record Name you want to check or create (e.g., example.com): " RECORD_NAME

    # Save the initial configuration to a file
    echo "API_KEY='$API_KEY'" > "$CONFIG_FILE"
    echo "EMAIL='$EMAIL'" >> "$CONFIG_FILE"
    echo "ZONE_ID='$ZONE_ID'" >> "$CONFIG_FILE"
    echo "RECORD_NAME='$RECORD_NAME'" >> "$CONFIG_FILE"

    # Check if the DNS record exists or needs to be created
    check_and_create_record
}

# Function to check if the DNS record exists and create if it does not
check_and_create_record() {
    RESPONSE=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?name=$RECORD_NAME" \
        -H "X-Auth-Email: $EMAIL" \
        -H "X-Auth-Key: $API_KEY" \
        -H "Content-Type: application/json")
    RECORD_ID=$(echo "$RESPONSE" | jq -r '.result[0].id')
    
    if [[ -z "$RECORD_ID" || "$RECORD_ID" == "null" ]]; then
        echo "Record does not exist, creating record..."
        create_dns_record
    else
        echo "Record already exists with ID: $RECORD_ID"
        echo "RECORD_ID='$RECORD_ID'" >> "$CONFIG_FILE"
        update_if_necessary
    fi
}

# Function to create a new DNS record
create_dns_record() {
    PUBLIC_IP=$(curl -s https://mypublicip.online)
    RESPONSE=$(curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records" \
        -H "X-Auth-Email: $EMAIL" \
        -H "X-Auth-Key: $API_KEY" \
        -H "Content-Type: application/json" \
        --data "{\"type\":\"A\",\"name\":\"$RECORD_NAME\",\"content\":\"$PUBLIC_IP\",\"ttl\":3600,\"proxied\":false}")
    RECORD_ID=$(echo "$RESPONSE" | jq -r '.result.id')

    if [[ "$RECORD_ID" != "null" ]]; then
        echo "New record created with ID: $RECORD_ID"
        echo "RECORD_ID='$RECORD_ID'" >> "$CONFIG_FILE"
        update_if_necessary
    else
        echo "Failed to create DNS record. Check API Key and Zone ID."
    fi
}

# Function to update the DNS record if the public IP has changed
update_if_necessary() {
    CURRENT_IP=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID" \
        -H "X-Auth-Email: $EMAIL" \
        -H "X-Auth-Key: $API_KEY" \
        -H "Content-Type: application/json" | jq -r '.result.content')
    PUBLIC_IP=$(curl -s https://mypublicip.online)

    if [[ "$PUBLIC_IP" != "$CURRENT_IP" ]]; then
        echo "Updating record to new IP: $PUBLIC_IP"
        curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID" \
             -H "X-Auth-Email: $EMAIL" \
             -H "X-Auth-Key: $API_KEY" \
             -H "Content-Type: application/json" \
             --data "{\"type\":\"A\",\"name\":\"$RECORD_NAME\",\"content\":\"$PUBLIC_IP\",\"ttl\":3600,\"proxied\":false}" | jq -r '.success'
    else
        echo "No update needed. Current IP matches Public IP."
    fi
}

# Start the script by loading the configuration or setting up if it's the first run
load_config
