#!/bin/bash
# Render CodexReserve's Apple-esque icon and build Resources/AppIcon.icns
set -euo pipefail
cd "$(dirname "$0")/.."

WORK="/tmp/CodexReserveIcon"
SET="$WORK/AppIcon.iconset"
mkdir -p "$WORK" "$SET" Resources

echo "→ rendering 1024 master"
swift icon/make-icon.swift "$WORK/icon_1024.png"

echo "→ downscaling iconset"
for s in 16 32 128 256 512; do
  sips -z $s $s "$WORK/icon_1024.png" --out "$SET/icon_${s}x${s}.png" >/dev/null
  d=$((s * 2))
  if [ "$d" -le 1024 ]; then
    sips -z $d $d "$WORK/icon_1024.png" --out "$SET/icon_${s}x${s}@2x.png" >/dev/null
  fi
done

echo "→ iconutil"
iconutil -c icns "$SET" -o Resources/AppIcon.icns
rm -rf "$SET"
echo "✓ Resources/AppIcon.icns"
