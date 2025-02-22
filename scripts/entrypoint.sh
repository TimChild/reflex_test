#!/bin/sh

echo "Starting the reflex backend in prod mode..."
reflex db migrate && reflex run --env prod --backend-only --loglevel info
