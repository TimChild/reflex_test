#!/bin/bash

set -e

cd reflex_test
git pull

docker compose build 
docker compose down
docker compose up -d

