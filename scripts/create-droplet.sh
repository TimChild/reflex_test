#!/bin/bash

set -e 

droplet_name=$1
ssh_key_id=$2

if [ -z "$droplet_name" ]; then
  echo "Usage: $0 <droplet_name> <ssh_key_id>"
  exit 1
fi

if [ -z "$ssh_key_id" ]; then
  echo "Usage: $0 <droplet_name> <ssh_key_id>"
  exit 1
fi

# Create a new droplet
doctl compute droplet create $droplet_name --image ubuntu-24-04-x64 --region sfo3 --size s-1vcpu-512mb-10gb --ssh-keys $ssh_key_id --enable-monitoring --wait

echo "Droplet created successfully!"

# Get the IP address of the new droplet
ip_address=$(doctl compute droplet list $droplet_name --format PublicIPv4 --no-header)

echo "Droplet IP address: $ip_address"

# Add droplet to ssh config (if it doesn't already exist)
if ! grep -q "Host $droplet_name" ~/.ssh/config; then
	echo "Adding droplet to ~/.ssh/config"
	echo "Host $droplet_name" >> ~/.ssh/config
	echo "  HostName $ip_address" >> ~/.ssh/config
	echo "  User root" >> ~/.ssh/config
else
	echo "Droplet already exists in ~/.ssh/config -- updating IP address"
	# replace the IP address (for the HostName of the Host $droplet_name)
	sed -i '' "/^Host $droplet_name$/,/^Host /{s/^  HostName .*/  HostName $ip_address/}" ~/.ssh/config
fi

# Wait for droplet to be accessible via SSH
echo "Waiting for droplet to be accessible via SSH..."
accessible=false
for ((i=0; i<20; i++)); do
      if ssh -o ConnectTimeout=2 -o -o BatchMode=yes -o UserKnownHostsFile=/dev/null $droplet_name true 2>/dev/null; then
	  accessible=true
	  echo "Droplet is accessible via SSH!"
	  break
      fi
      echo "Not accessible yet ($i)..."
done

if [ "$accessible" = false ]; then
	echo "Droplet is not accessible via SSH after 20 tries. Exiting..."
	exit 1
fi

# Install unzip on the droplet
ssh $droplet_name "apt-get update && apt-get install -y unzip"

