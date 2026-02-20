#!/usr/bin/env bash

# Content Coach Installer (macOS)
# Detects existing install location and replaces in-place. Uses sudo only for /Applications.
# Usage: curl -fsSL https://raw.githubusercontent.com/jazonh/Electron-Content-Coach-Releases/main/install.sh | bash

set -euo pipefail

VERSION="${1:-latest}"
REPO="jazonh/Electron-Content-Coach-Releases"
APP_NAME="Content Coach"
WORK_DIR="$(mktemp -d)"

log()  { printf "%s %s\n" "$1" "$2"; }
die()  { log "❌" "$1"; exit 1; }
cleanup() { rm -rf "$WORK_DIR" 2>/dev/null || true; }
trap cleanup EXIT

check_vpn() {
  local vpn_active=false
  if scutil --nwi 2>/dev/null | grep -qi 'ipsec\|vpn'; then
    vpn_active=true
  elif networksetup -listallnetworkservices 2>/dev/null | grep -qi 'vpn\|cisco\|globalprotect\|zscaler\|pulse'; then
    local svc
    while IFS= read -r svc; do
      if networksetup -showpppoestatus "$svc" 2>/dev/null | grep -qi 'connected'; then
        vpn_active=true
        break
      fi
    done < <(networksetup -listallnetworkservices 2>/dev/null | grep -i 'vpn\|cisco\|globalprotect\|zscaler\|pulse')
  fi

  if $vpn_active; then
    echo ""
    log "⚠️"  "VPN appears to be active."
    log "📡" "GitHub downloads often fail on corporate VPN."
    log "💡" "If the download fails, disconnect VPN and re-run this script."
    echo ""
  fi
}

fetch_release_info() {
  RELEASE_JSON=$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest") \
    || die "Could not reach GitHub API. Are you connected to the internet (and off VPN)?"
}

parse_tag() {
  local tag
  tag=$(printf "%s" "$RELEASE_JSON" | sed -n 's/.*"tag_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n 1)
  [[ -n "$tag" ]] || die "Could not determine latest version"
  printf "%s" "$tag"
}

find_dmg_url() {
  local url
  url=$(printf "%s" "$RELEASE_JSON" | grep '"browser_download_url"' | grep -i 'arm64\.dmg"' | sed -E 's/.*"(https[^"]+)".*/\1/' | head -n 1)
  [[ -n "$url" ]] || die "No arm64 DMG found in release assets"
  printf "%s" "$url"
}

quit_running_app() {
  if pgrep -xq "$APP_NAME"; then
    log "🛑" "Content Coach is running — quitting it now..."
    osascript -e "tell application \"$APP_NAME\" to quit" 2>/dev/null || true
    sleep 2
    if pgrep -xq "$APP_NAME"; then
      pkill -x "$APP_NAME" 2>/dev/null || true
      sleep 1
    fi
    log "✓" "App closed"
  fi
}

main() {
  log "📦" "Content Coach Installer"
  echo ""

  check_vpn

  log "🔍" "Fetching release info..."
  fetch_release_info

  if [[ "$VERSION" == "latest" ]]; then
    VERSION=$(parse_tag)
    log "✓"  "Latest version: $VERSION"
  fi

  local download_url dmg_name dmg_path
  local app_src app_dest

  download_url=$(find_dmg_url)
  dmg_name="${download_url##*/}"
  dmg_path="$WORK_DIR/$dmg_name"

  log "📥" "Downloading $dmg_name..."
  curl -fL --retry 3 --retry-delay 2 --progress-bar -o "$dmg_path" "$download_url" \
    || die "Download failed. If on VPN, disconnect and try again."
  log "✓" "Download complete"

  log "🔓" "Removing quarantine flag..."
  /usr/bin/xattr -cr "$dmg_path" 2>/dev/null || true

  log "💿" "Mounting DMG..."
  local mount_output mount_point
  mount_output=$(hdiutil attach "$dmg_path" -nobrowse -noverify -noautoopen 2>&1) \
    || die "Failed to mount DMG"
  mount_point=$(echo "$mount_output" | grep -o '/Volumes/.*' | head -n 1)
  [[ -d "$mount_point" ]] || die "Could not find mount point"

  app_src=$(find "$mount_point" -maxdepth 1 -name "*.app" | head -n 1)
  [[ -d "$app_src" ]] || { hdiutil detach "$mount_point" -quiet 2>/dev/null; die "No .app found in DMG"; }

  quit_running_app

  # Detect where the existing install lives; prefer /Applications (standard DMG target)
  local install_dir use_sudo=false
  if [[ -d "/Applications/$APP_NAME.app" ]]; then
    install_dir="/Applications"
    use_sudo=true
  elif [[ -d "$HOME/Applications/$APP_NAME.app" ]]; then
    install_dir="$HOME/Applications"
  else
    install_dir="/Applications"
    use_sudo=true
  fi

  app_dest="$install_dir/$APP_NAME.app"

  if [[ -d "$app_dest" ]]; then
    log "♻️"  "Removing previous version from $install_dir..."
    if $use_sudo; then
      sudo rm -rf "$app_dest"
    else
      rm -rf "$app_dest"
    fi
  fi

  log "📂" "Installing to $install_dir..."
  if $use_sudo; then
    sudo cp -R "$app_src" "$app_dest"
    sudo /usr/bin/xattr -cr "$app_dest" 2>/dev/null || true
  else
    mkdir -p "$install_dir"
    cp -R "$app_src" "$app_dest"
    /usr/bin/xattr -cr "$app_dest" 2>/dev/null || true
  fi

  # Clean up stale copy in the other location if it exists
  local other_dir
  if [[ "$install_dir" == "/Applications" && -d "$HOME/Applications/$APP_NAME.app" ]]; then
    other_dir="$HOME/Applications/$APP_NAME.app"
  elif [[ "$install_dir" == "$HOME/Applications" && -d "/Applications/$APP_NAME.app" ]]; then
    other_dir="/Applications/$APP_NAME.app"
  fi
  if [[ -n "${other_dir:-}" ]]; then
    log "🧹" "Removing stale copy at $other_dir..."
    sudo rm -rf "$other_dir" 2>/dev/null || rm -rf "$other_dir" 2>/dev/null || true
  fi

  log "💿" "Cleaning up..."
  hdiutil detach "$mount_point" -quiet 2>/dev/null || true

  echo ""
  log "✅" "Content Coach $VERSION installed!"
  log "📍" "Location: $app_dest"
  echo ""

  if [[ -t 0 ]]; then
    read -rp "🚀 Launch Content Coach now? [Y/n] " answer
    answer="${answer:-y}"
  else
    answer="y"
  fi

  if [[ "$answer" =~ ^[Yy]$ ]]; then
    open "$app_dest"
    log "🚀" "Launched!"
  else
    log "💡" "Run:  open \"$app_dest\""
  fi
}

main "$@"
