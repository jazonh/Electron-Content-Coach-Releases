#!/bin/bash

# Content Coach Installation Script
# This script downloads and installs Content Coach, bypassing macOS Gatekeeper

set -e  # Exit on error

VERSION="${1:-latest}"  # Default to latest if no version specified
REPO="jazonh/Electron-Content-Coach-Releases"
APP_NAME="Content-Coach"

echo "📦 Installing Content Coach..."

# Get latest release info from GitHub
if [ "$VERSION" = "latest" ]; then
  echo "🔍 Fetching latest version..."
  RELEASE_INFO=$(curl -s "https://api.github.com/repos/$REPO/releases/latest")
  VERSION=$(echo "$RELEASE_INFO" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
  echo "✓ Latest version: $VERSION"
fi

# Construct download URL
DMG_NAME="$APP_NAME-${VERSION#v}-arm64.dmg"
DOWNLOAD_URL="https://github.com/$REPO/releases/download/$VERSION/$DMG_NAME"

echo "📥 Downloading $DMG_NAME..."
TMP_DIR=$(mktemp -d)
DMG_PATH="$TMP_DIR/$DMG_NAME"

curl -L -o "$DMG_PATH" "$DOWNLOAD_URL"

echo "✓ Download complete"

# Remove quarantine attribute to bypass Gatekeeper
echo "🔓 Removing quarantine attribute..."
xattr -cr "$DMG_PATH"

# Mount the DMG
echo "💿 Mounting DMG..."
MOUNT_POINT=$(hdiutil attach "$DMG_PATH" | grep "Volumes" | awk '{print $3}')

# Copy app to Applications
echo "📂 Installing to /Applications..."
sudo rm -rf "/Applications/$APP_NAME.app"
sudo cp -R "$MOUNT_POINT/$APP_NAME.app" /Applications/

# Remove quarantine from installed app
echo "🔓 Removing quarantine from installed app..."
sudo xattr -cr "/Applications/$APP_NAME.app"

# Unmount and cleanup
echo "🧹 Cleaning up..."
hdiutil detach "$MOUNT_POINT" -quiet
rm -rf "$TMP_DIR"

echo "✅ Content Coach installed successfully!"
echo "🚀 You can now launch it from /Applications/$APP_NAME.app"
echo ""
echo "💡 To launch from terminal: open -a \"$APP_NAME\""
