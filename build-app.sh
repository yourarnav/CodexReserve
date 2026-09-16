#!/bin/bash
# Build CodexBar.app (menu-bar-only, no Dock icon via LSUIElement)
set -euo pipefail
cd "$(dirname "$0")"

APP="CodexBar.app"
IDENTIFIER="com.codexbar.app"

echo "→ swift build -c release"
swift build -c release

echo "→ bundling $APP"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"

cp ".build/release/CodexBar" "$APP/Contents/MacOS/CodexBar"
chmod +x "$APP/Contents/MacOS/CodexBar"

# App icon (Apple-esque squircle + double ring). Regenerate with ./icon/make-icon.sh
if [ ! -f Resources/AppIcon.icns ]; then
  ./icon/make-icon.sh
fi
cp Resources/AppIcon.icns "$APP/Contents/Resources/AppIcon.icns"

cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key><string>CodexBar</string>
    <key>CFBundleIdentifier</key><string>$IDENTIFIER</string>
    <key>CFBundleName</key><string>CodexBar</string>
    <key>CFBundleDisplayName</key><string>CodexBar</string>
    <key>CFBundleVersion</key><string>1.0</string>
    <key>CFBundleShortVersionString</key><string>1.0</string>
    <key>CFBundlePackageType</key><string>APPL</string>
    <key>CFBundleIconFile</key><string>AppIcon</string>
    <key>LSUIElement</key><true/>
    <key>NSHighResolutionCapable</key><true/>
    <key>LSMinimumSystemVersion</key><string>14.0</string>
</dict>
</plist>
PLIST

echo "✓ Built $APP — open it with: open $APP"
echo "  (first run: allow it to read ~/.codex/auth.json — no sandbox, no data leaves your Mac except the official ChatGPT usage endpoint)"
