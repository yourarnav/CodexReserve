#!/bin/bash
# Install CodexReserve to /Applications for Launchpad + Spotlight presence.
# NOTE: deliberately NO login autostart — the user opens CodexReserve manually
# while Codex runs, and it quits itself when Codex quits. Do NOT add a
# LaunchAgent or Login Item here.
set -euo pipefail
cd "$(dirname "$0")"

./build-app.sh

echo "→ installing to /Applications (no autostart)"
pkill -x CodexReserve 2>/dev/null || true
sleep 1
rm -rf "/Applications/CodexReserve.app"
cp -R "CodexReserve.app" "/Applications/CodexReserve.app"
touch "/Applications/CodexReserve.app"
echo "✓ Installed to /Applications/CodexReserve.app — open it manually while Codex runs."
