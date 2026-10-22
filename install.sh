#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Build first if not already built
if [ ! -d "$SCRIPT_DIR/MenuBarCalendar.app" ]; then
    ./build.sh
fi

echo "📦 Installing MenuBarCalendar to /Applications..."

# Terminate existing instance if running
if pgrep -x "MenuBarCalendar" > /dev/null; then
    echo "Stopping running instance..."
    killall "MenuBarCalendar" || true
    sleep 1
fi

DEST="/Applications/MenuBarCalendar.app"
rm -rf "$DEST"
cp -R "$SCRIPT_DIR/MenuBarCalendar.app" "$DEST"
xattr -cr "$DEST"
codesign --force --deep --sign - "$DEST"

# Ensure date is removed from menu bar by default
defaults write com.antigravity.MenuBarCalendar showDateInMenuBar -bool false 2>/dev/null || true

echo "🚀 Launching MenuBarCalendar from /Applications..."
open "$DEST"

echo "🎉 Installed and launched successfully! Look for the calendar icon in your top menu bar."
