#!/usr/bin/env bash
set -e

chmod +x scripts/res-switch
chmod +x scripts/res-reset
chmod +x init.d/99-install-res-switch.sh

docker compose down
docker compose up -d
