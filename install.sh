#!/bin/bash

# Smart Install Script for Electron Content Coach
# Based on the proven Content Coach installation system
# Handles quarantine removal and provides seamless installation experience

set -e

echo "🚀 Electron Content Coach - Smart Installer"
echo "=========================================="
echo ""

# Configuration
REPO="jazonh/Electron-Content-Coach-Releases"
APP_NAME="Electron Next App"
TEMP_DIR="/tmp/electron-content-coach-install"

# Check if running on macOS
if [[ "$(uname)" != "Darwin" ]]; then
    echo "❌ This installer is for macOS only."
    exit 1
fi

# Check for required tools
if ! command -v curl &> /dev/null; then
    echo "❌ curl is required but not installed."
    exit 1
fi

if ! command -v unzip &> /dev/null; then
    echo "❌ unzip is required but not installed."
    exit 1
fi

echo "📋 Installing Electron Content Coach..."
echo ""

# Create temporary directory
echo "📁 Creating temporary directory..."
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"
cd "$TEMP_DIR"

# Get latest release information
echo "🔍 Finding latest version..."
LATEST_URL="https://api.github.com/repos/$REPO/releases/latest"
DOWNLOAD_URL=$(curl -s "$LATEST_URL" | grep -o 'https://github.com/[^"]*\.dmg' | head -1)

if [ -z "$DOWNLOAD_URL" ]; then
    echo "❌ Could not find latest release. Please check your internet connection."
    exit 1
fi

VERSION=$(echo "$DOWNLOAD_URL" | grep -o 'v[0-9]\+\.[0-9]\+\.[0-9]\+' | head -1)
echo "✅ Found latest version: $VERSION"

# Download latest version
echo "📥 Downloading $VERSION..."
DMG_FILE="electron-content-coach-latest.dmg"
curl -L -o "$DMG_FILE" "$DOWNLOAD_URL"

if [ ! -f "$DMG_FILE" ]; then
    echo "❌ Download failed."
    exit 1
fi

echo "✅ Download complete"

# Mount the DMG
echo "📦 Mounting disk image..."
MOUNT_POINT=$(hdiutil attach "$DMG_FILE" | grep Volumes | awk '{print $3}')

if [ -z "$MOUNT_POINT" ]; then
    echo "❌ Failed to mount disk image."
    exit 1
fi

# Find the app in the mounted volume
if [ ! -d "$MOUNT_POINT/$APP_NAME.app" ]; then
    echo "❌ Application not found in downloaded package."
    hdiutil detach "$MOUNT_POINT" 2>/dev/null || true
    exit 1
fi

# Remove quarantine attributes (critical for seamless updates)
echo "🔓 Removing quarantine attributes..."
xattr -dr com.apple.quarantine "$MOUNT_POINT/$APP_NAME.app" 2>/dev/null || true

# Remove existing installation if present
if [ -d "/Applications/$APP_NAME.app" ]; then
    echo "🗑️  Removing previous installation..."
    rm -rf "/Applications/$APP_NAME.app"
fi

# Install to Applications
echo "📋 Installing to Applications folder..."
cp -R "$MOUNT_POINT/$APP_NAME.app" "/Applications/"

# Unmount the DMG
echo "💿 Unmounting disk image..."
hdiutil detach "$MOUNT_POINT" 2>/dev/null || true

# Remove quarantine attributes again after installation (ensures it sticks)
echo "🔓 Final quarantine removal..."
xattr -dr com.apple.quarantine "/Applications/$APP_NAME.app" 2>/dev/null || true

if [ ! -d "/Applications/$APP_NAME.app" ]; then
    echo "❌ Installation failed."
    exit 1
fi

# Cleanup
echo "🧹 Cleaning up temporary files..."
cd /
rm -rf "$TEMP_DIR"

echo ""
echo "🎉 Installation Complete!"
echo "========================"
echo ""
echo "✅ Electron Content Coach $VERSION has been installed successfully!"
echo ""
echo "⚠️  If macOS prevents the app from opening:"
echo "   1. Right-click '$APP_NAME.app' in Applications → Open"
echo "   2. Or run: sudo xattr -dr com.apple.quarantine '/Applications/$APP_NAME.app'"
echo "   3. Or go to System Preferences → Security & Privacy → General → Open Anyway"
echo ""
echo "📱 **Next Steps:**"
echo "   1. Open Electron Content Coach from Applications folder"
echo "   2. Ensure your .env file is configured with Supabase credentials"
echo "   3. Start correcting tone with AI-powered RAG suggestions!"
echo ""
echo "🔄 **Automatic Updates:**"
echo "   The app will automatically check for updates and notify you when new versions are available."
echo "   Future updates will install seamlessly without additional setup."
echo ""
echo "🚀 **Opening Electron Content Coach now...**"

# Open the application
open "/Applications/$APP_NAME.app"

echo ""
echo "Thank you for using Electron Content Coach! 🎊"
echo ""
echo "💡 **Tips:**"
echo "   • The app uses PyChomsky embeddings for intelligent guideline retrieval"
echo "   • RAG system searches Supabase vector database for relevant brand guidelines"
echo "   • GPT-5 Mini reasoning model provides intelligent tone correction"
echo "   • Get 3 alternative versions with different approaches"
echo ""
echo "🔗 **Resources:**"
echo "   • GitHub: https://github.com/jazonh/Electron-Content-Coach"
echo "   • Releases: https://github.com/$REPO"
echo ""
echo "✨ Installation complete - enjoy your enhanced brand communication!"
