#!/usr/bin/env bash

# Content Coach Installation Script (macOS)
# - No sudo required (installs per-user if /Applications is not writable)
# - Quits any running instance
# - Removes quarantine attributes

set -euo pipefail

VERSION="${1:-latest}"
REPO="jazonh/Electron-Content-Coach-Releases"
APP_BUNDLE_NAME="Content-Coach.app"
APP_PROCESS_1="Content-Coach"
APP_PROCESS_2="Content Coach"

log() { printf "%s %s\n" "$1" "$2"; }

die() {
  log "❌" "$1"
  exit 1
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

  /usr/bin/osascript -e "try" -e "tell application \"$APP_PROCESS_1\" to quit" -e "end try" >/dev/null 2>&1 || true
  /usr/bin/osascript -e "try" -e "tell application \"$APP_PROCESS_2\" to quit" -e "end try" >/dev/null 2>&1 || true

  /usr/bin/pkill -x "$APP_PROCESS_1" >/dev/null 2>&1 || true
  /usr/bin/pkill -x "$APP_PROCESS_2" >/dev/null 2>&1 || true

  for _ in {1..50}; do
    if ! /usr/bin/pgrep -x "$APP_PROCESS_1" >/dev/null 2>&1 && ! /usr/bin/pgrep -x "$APP_PROCESS_2" >/dev/null 2>&1; then
      break
    fi
    /bin/sleep 0.2
  done
}

mount_dmg() {
  local dmg="$1" attach_out mount_point

  # Tab-delimited output; mount point can contain spaces.
  attach_out=$(hdiutil attach "$dmg" -nobrowse -readonly)
  mount_point=$(printf "%s\n" "$attach_out" | awk -F"\t" "/\\/Volumes\\// {print \$NF; exit}")

  [[ -n "$mount_point" ]] || die "Failed to determine DMG mount point"
  printf "%s" "$mount_point"
}

find_app_in_mount() {
  local mount_point="$1" app

  if [[ -d "$mount_point/$APP_BUNDLE_NAME" ]]; then
    printf "%s" "$mount_point/$APP_BUNDLE_NAME"
    return 0
  fi

  app=$(find "$mount_point" -maxdepth 1 -name "*.app" -print -quit)
  [[ -n "$app" ]] || die "Could not find an .app in mounted DMG at $mount_point"
  printf "%s" "$app"
}

choose_install_dir() {
  # Prefer /Applications if it is writable; otherwise install per-user.
  if [[ -w "/Applications" ]]; then
    printf "%s" "/Applications"
  else
    printf "%s" "$HOME/Applications"
  fi
}

main() {
  log "📦" "Installing Content Coach..."

  if [[ "$VERSION" == "latest" ]]; then
    log "🔍" "Fetching latest version..."
    VERSION=$(fetch_latest_tag)
    log "✓" "Latest version: $VERSION"
  fi

  local dmg_name="Content-Coach-${VERSION#v}-arm64.dmg"
  local download_url="https://github.com/$REPO/releases/download/$VERSION/$dmg_name"

  log "📥" "Downloading $dmg_name..."
  local tmp_dir dmg_path mount_point app_source install_dir install_path
  tmp_dir=$(mktemp -d)
  dmg_path="$tmp_dir/$dmg_name"

  curl -fL --retry 3 --retry-delay 1 -o "$dmg_path" "$download_url"
  log "✓" "Download complete"

  log "🔓" "Removing quarantine attribute from DMG..."
  /usr/bin/xattr -cr "$dmg_path" || true

  quit_running_app

  log "💿" "Mounting DMG..."
  mount_point=$(mount_dmg "$dmg_path")

  app_source=$(find_app_in_mount "$mount_point")

  install_dir=$(choose_install_dir)
  install_path="$install_dir/$APP_BUNDLE_NAME"

  log "📂" "Installing to $install_dir..."
  /bin/mkdir -p "$install_dir"
  /bin/rm -rf "$install_path"
  /usr/bin/ditto "$app_source" "$install_path"

  log "🔓" "Removing quarantine from installed app..."
  /usr/bin/xattr -cr "$install_path" || true

  log "🧹" "Cleaning up..."
  hdiutil detach "$mount_point" -quiet || hdiutil detach "$mount_point" -force -quiet || true
  /bin/rm -rf "$tmp_dir"

  log "✅" "Content Coach installed successfully!"
  log "🚀" "Launch: open \"$install_path\""

  if [[ "$install_dir" != "/Applications" ]]; then
    log "ℹ️" "Installed per-user because /Applications isn’t writable without admin."
  fi
}

main "$@"
