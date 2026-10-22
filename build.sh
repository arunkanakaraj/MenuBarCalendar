#!/bin/bash
set -e

APP_NAME="MenuBarCalendar"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "🔨 Building $APP_NAME..."

APP_BUNDLE="$SCRIPT_DIR/$APP_NAME.app"
MACOS_DIR="$APP_BUNDLE/Contents/MacOS"
RESOURCES_DIR="$APP_BUNDLE/Contents/Resources"

# Clear source attributes
xattr -cr Resources Sources 2>/dev/null || true

# Clean old bundle
rm -rf "$APP_BUNDLE"
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR"

# Copy Info.plist and Icons
cp "Resources/Info.plist" "$APP_BUNDLE/Contents/"
if [ -f "Resources/AppIcon.icns" ]; then
    cp "Resources/AppIcon.icns" "$RESOURCES_DIR/"
fi

# Compile Swift files
MODULE_CACHE="/tmp/mcache"
mkdir -p "$MODULE_CACHE"

SOURCES=(
    "Sources/SettingsModel.swift"
    "Sources/LaunchAtLogin.swift"
    "Sources/CalendarViewModel.swift"
    "Sources/CalendarView.swift"
    "Sources/StatusItemManager.swift"
    "Sources/AppDelegate.swift"
    "Sources/main.swift"
)

echo "📦 Compiling Swift sources..."
swiftc -O \
    -module-cache-path "$MODULE_CACHE" \
    -Xcc -fmodules-cache-path="$MODULE_CACHE" \
    -Xfrontend -disable-sandbox \
    -framework AppKit \
    -framework SwiftUI \
    -framework ServiceManagement \
    "${SOURCES[@]}" \
    -o "$MACOS_DIR/$APP_NAME"

# Clear extended attributes before signing
xattr -cr "$APP_BUNDLE"

# Ad-hoc code sign for macOS
echo "🔏 Signing application bundle..."
codesign --force --deep --sign - "$APP_BUNDLE"

echo "✅ Build successful: $APP_BUNDLE"
