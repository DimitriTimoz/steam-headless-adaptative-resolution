#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

SERVICE="${SERVICE:-steam-headless}"

docker compose exec "$SERVICE" bash -lc '
set -e

APPS_JSON="/home/default/.config/sunshine/apps.json"

if [ -f "${APPS_JSON}.res-switch.bak" ]; then
  cp "${APPS_JSON}.res-switch.bak" "$APPS_JSON"
else
  python3 - <<'"'"'PY'"'"'
import json
from pathlib import Path

path = Path("/home/default/.config/sunshine/apps.json")

with path.open("r", encoding="utf-8") as f:
    data = json.load(f)

for app in data.get("apps", []):
    prep = app.get("prep-cmd")
    if not prep:
        continue

    prep = [
        cmd for cmd in prep
        if "/home/default/bin/res-switch" not in cmd.get("do", "")
    ]

    if prep:
        app["prep-cmd"] = prep
    else:
        app.pop("prep-cmd", None)

with path.open("w", encoding="utf-8") as f:
    json.dump(data, f, indent=2)
PY
fi

rm -f /home/default/init.d/99-install-res-switch.sh

supervisorctl restart sunshine
'

echo "[res-switch] Uninstalled."
