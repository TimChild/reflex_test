#!/bin/bash

# Assuming new frontend.zip and backend.zip are already on the server, this will extract those contents and restart
# the relevant services.

set -e

cd reflex_test

# Remove existing frontend and backend directories
rm -rf frontend
rm -rf backend

# Unzip the new frontend and backend
unzip -o frontend.zip -d frontend
unzip -o backend.zip -d backend

# Restart the services
docker compose restart
