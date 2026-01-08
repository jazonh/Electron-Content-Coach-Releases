#!/usr/bin/env bash

# Content Coach Installation Script (macOS)
# - Downloads the latest DMG from GitHub Releases
# - Quits any running instance
# - Installs into /Applications
# - Removes quarantine attributes

set -euo pipefail

VERSION="${1:-latest}"
REPO="jazonh/Electron-Content-Coach-Releases"
APP_BUNDLE="Content-Coach.app"
APP_PROCESS_1="Content-Coach"
APP_PROCESS_2="Content Coach"

log() { printf "%s %s\n" "$1" "$2"; }

die() {
  log "❌" "$1"
  exit 1
}

require_root() {
  if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
    die "Please run with sudo (e.g. curl ... | sudo bash)"
  fi
}

fetch_latest_tag() {
  local info tag
  info=$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest")
  tag=$(printf "%s" "$info" | sed -n "s/.*\"tag_name\"[[:space:]]*:[[:space:]]*\"\([^\"]*\)\".*/\1/p" | head -n 1)
  [[ -n "$tag" ]] || die "Could not determine latest version (tag_name missing)"
  printf "%s" "$tag"
}

quit_running_app() {
  log "🛑" "Quitting any running Content Coach instances..."

  # Best-effort graceful quit
  /usr/bin/osascript -e "try" \
    -e "tell application \"$APP_PROCESS_1\" to quit" \
    -e "end try" >/dev/null 2>&1 || true
  /usr/bin/osascript -e "try" \
    -e "tell application \"$APP_PROCESS_2\" to quit" \
    -e "end try" >/dev/null 2>&1 || true

  # Best-effort hard kill
  /usr/bin/pkill -x "$APP_PROCESS_1" >/dev/null 2>&1 || true
  /usr/bin/pkill -x "$APP_PROCESS_2" >/dev/null 2>&1 || true

  # Wait a moment for processes to exit
  for _ in {1..50}; do
    if ! /usr/bin/pgrep -x "$APP_PROCESS_1" >/dev/null 2>&1 && ! /usr/bin/pgrep -x "$APP_PROCESS_2" >/dev/null 2>&1; then
      break
    fi
    /bin/sleep 0.2
  done
}

mount_dmg() {
  local dmg="$1" attach_out mount_point

  # hdiutil output is tab-delimited; mount point can contain spaces.
  attach_out=$(hdiutil attach "$dmg" -nobrowse -readonly)
  mount_point=$(printf "%s\n" "$attach_out" | awk -F"\t" "/\\/Volumes\\// {print \$NF; exit}")

  [[ -n "$mount_point" ]] || die "Failed to determine DMG mount point"
  printf "%s" "$mount_point"
}

find_app_in_mount() {
  local mount_point="$1" app

  # Prefer exact bundle name if present.
  if [[ -d "$mount_point/$APP_BUNDLE" ]]; then
    printf "%s" "$mount_point/$APP_BUNDLE"
    return 0
  fi

  # Fallback: first .app found at root.
  app=$(find "$mount_point" -maxdepth 1 -name "*.app" -print -quit)
  [[ -n "$app" ]] || die "Could not find an .app in mounted DMG at $mount_point"
  printf "%s" "$app"
}

main() {
  require_root

  log "📦" "Installing Content Coach..."

  if [[ "$VERSION" == "latest" ]]; then
    log "🔍" "Fetching latest version..."
    VERSION=$(fetch_latest_tag)
    log "✓" "Latest version: $VERSION"
  fi

  local dmg_name="Content-Coach-${VERSION#v}-arm64.dmg"
  local download_url="https://github.com/$REPO/releases/download/$VERSION/$dmg_name"

  log "📥" "Downloading $dmg_name..."
  local tmp_dir dmg_path mount_point app_source
  tmp_dir=$(mktemp -d)
  dmg_path="$tmp_dir/$dmg_name"

  curl -fL --retry 3 --retry-delay 1 -o "$dmg_path" "$download_url"
  log "✓" "Download complete"

  log "🔓" "Removing quarantine attribute from DMG..."
  /usr/bin/xattr -cr "$dmg_path" || true

  quit_running_app

  log "💿" "Mounting DMG..."
  mount_point=$(mount_dmg "$dmg_path")

  log "📂" "Installing to /Applications..."
  app_source=$(find_app_in_mount "$mount_point")

  /bin/rm -rf "/Applications/$APP_BUNDLE"
  /usr/bin/ditto "$app_source" "/Applications/$APP_BUNDLE"

  log "🔓" "Removing quarantine from installed app..."
  /usr/bin/xattr -cr "/Applications/$APP_BUNDLE" || true

  log "🧹" "Cleaning up..."
  hdiutil detach "$mount_point" -quiet || hdiutil detach "$mount_point" -force -quiet || true
  /bin/rm -rf "$tmp_dir"

  log "✅" "Content Coach installed successfully!"
  log "🚀" "Launch from Finder or: open -a \"${APP_PROCESS_1}\""
}

main "$@"
