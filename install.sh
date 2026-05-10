#!/usr/bin/env bash
set -e

chmod +x scripts/res-switch
chmod +x scripts/moonlight-res-reset

docker compose down
docker compose up -d
