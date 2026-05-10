#!/usr/bin/env bash
set -e

APPS_JSON="/home/default/.config/sunshine/apps.json"

echo "[res-switch] Installing Sunshine resolution switch hook..."

mkdir -p /home/default/bin
mkdir -p /home/default/.cache/log

chmod +x /home/default/bin/res-switch || true
chmod +x /home/default/bin/res-reset || true

if [ ! -f "$APPS_JSON" ]; then
  echo "[res-switch] apps.json not found yet: $APPS_JSON"
  exit 0
fi

cp "$APPS_JSON" "${APPS_JSON}.res-switch.bak"

python3 - <<'PY'
import json
from pathlib import Path

path = Path("/home/default/.config/sunshine/apps.json")

with path.open("r", encoding="utf-8") as f:
    data = json.load(f)

hook = {
    "do": "bash /home/default/bin/res-switch",
    "undo": "bash /home/default/bin/res-reset",
    "elevated": False,
}

apps = data.get("apps", [])

for app in apps:
    # On patche Desktop, sans remplacer le reste de sa config.
    if app.get("name") == "Desktop":
        prep = app.get("prep-cmd", [])

        # Évite les doublons si le conteneur redémarre.
        prep = [
            cmd for cmd in prep
            if "/home/default/bin/res-switch" not in cmd.get("do", "")
        ]

        prep.insert(0, hook)
        app["prep-cmd"] = prep

data["apps"] = apps

with path.open("w", encoding="utf-8") as f:
    json.dump(data, f, indent=2)

print("[res-switch] apps.json patched successfully")
PY

echo "[res-switch] Done."
