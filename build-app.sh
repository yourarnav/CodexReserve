#!/bin/bash
# Build CodexReserve.app (menu-bar-only, no Dock icon via LSUIElement)
set -euo pipefail
cd "$(dirname "$0")"

APP="CodexReserve.app"
IDENTIFIER="com.codexreserve.app"

echo "→ swift build -c release (universal: arm64 + x86_64)"
swift build -c release --arch arm64
swift build -c release --arch x86_64
# Dedicated output dir: .build/release is an SPM symlink into one arch dir,
# so writing lipo output there mutates its own input and breaks repeat builds
# with duplicate-architecture errors. A separate dir stays clean.
mkdir -p ".build/universal"
lipo -create \
  ".build/arm64-apple-macosx/release/CodexReserve" \
  ".build/x86_64-apple-macosx/release/CodexReserve" \
  -output ".build/universal/CodexReserve"
lipo -info ".build/universal/CodexReserve"

echo "→ bundling $APP"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"

cp ".build/universal/CodexReserve" "$APP/Contents/MacOS/CodexReserve"
chmod +x "$APP/Contents/MacOS/CodexReserve"

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
    <key>CFBundleExecutable</key><string>CodexReserve</string>
    <key>CFBundleIdentifier</key><string>$IDENTIFIER</string>
    <key>CFBundleName</key><string>CodexReserve</string>
    <key>CFBundleDisplayName</key><string>CodexReserve</string>
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
