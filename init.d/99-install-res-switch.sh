#!/usr/bin/env bash
set -euo pipefail

APPS_JSON="/home/default/.config/sunshine/apps.json"
LOG="/home/default/.cache/log/res-switch-install.log"

mkdir -p /home/default/.cache/log

{
  echo ""
  echo "---- $(date) ----"
  echo "[res-switch] Installing Sunshine resolution switch hook..."

  if [ ! -f "$APPS_JSON" ]; then
    echo "[res-switch] ERROR: apps.json not found: $APPS_JSON"
    exit 0
  fi

  cp "$APPS_JSON" "${APPS_JSON}.res-switch.bak" || true

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

patched = False

for app in data.get("apps", []):
    if app.get("name") == "Desktop":
        prep = app.get("prep-cmd", [])

        # Avoid duplicate hook on repeated installs.
        prep = [
            cmd for cmd in prep
            if "/home/default/bin/res-switch" not in cmd.get("do", "")
        ]

        prep.insert(0, hook)
        app["prep-cmd"] = prep
        patched = True

if not patched:
    raise SystemExit("Desktop app not found in apps.json")

with path.open("w", encoding="utf-8") as f:
    json.dump(data, f, indent=2)

print("[res-switch] apps.json patched successfully")
PY

  echo "[res-switch] Done."

} >> "$LOG" 2>&1
