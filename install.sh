#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

SERVICE="${SERVICE:-steam-headless}"

echo "[res-switch] Preparing local files..."

chmod +x scripts/res-switch
chmod +x scripts/res-reset
chmod +x install/99-install-res-switch.sh

echo "[res-switch] Starting container with override..."
docker compose up -d --force-recreate

echo "[res-switch] Waiting for container..."
sleep 5

echo "[res-switch] Installing init.d hook into persistent home..."

docker compose exec "$SERVICE" bash -lc '
set -e

mkdir -p /home/default/init.d

cp /opt/res-switch/99-install-res-switch.sh /home/default/init.d/99-install-res-switch.sh
chmod +x /home/default/init.d/99-install-res-switch.sh

bash /home/default/init.d/99-install-res-switch.sh

supervisorctl restart sunshine
'

echo "[res-switch] Install complete."
echo ""
echo "Check install log:"
echo "  docker compose exec $SERVICE cat /home/default/.cache/log/res-switch-install.log"
echo ""
echo "Check Sunshine apps.json:"
echo "  docker compose exec $SERVICE grep -A10 -B3 res-switch /home/default/.config/sunshine/apps.json"
echo ""
echo "Check resolution switch log after Moonlight connect:"
echo "  docker compose exec $SERVICE tail -f /home/default/.cache/log/moonlight-res-switch.log"
