#!/bin/bash
# Install CodexBar to /Applications for Launchpad + Spotlight presence.
# NOTE: deliberately NO login autostart — the user opens CodexBar manually
# while Codex runs, and it quits itself when Codex quits. Do NOT add a
# LaunchAgent or Login Item here.
set -euo pipefail
cd "$(dirname "$0")"

./build-app.sh

echo "→ installing to /Applications (no autostart)"
pkill -x CodexBar 2>/dev/null || true
sleep 1
rm -rf "/Applications/CodexBar.app"
cp -R "CodexBar.app" "/Applications/CodexBar.app"
touch "/Applications/CodexBar.app"
echo "✓ Installed to /Applications/CodexBar.app — open it manually while Codex runs."
