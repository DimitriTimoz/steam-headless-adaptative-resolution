#!/usr/bin/env bash
set -e

chmod +x scripts/res-switch
chmod +x scripts/moonlight-res-reset
chmod +x init.d/20-clean-xrandr.sh

docker compose down
docker compose up -d
