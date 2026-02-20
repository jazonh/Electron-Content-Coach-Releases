#!/usr/bin/env bash

# Content Coach Installation Script (macOS)
# Downloads the DMG and opens it for manual drag-and-drop install

set -euo pipefail

VERSION="${1:-latest}"
REPO="jazonh/Electron-Content-Coach-Releases"

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

main() {
  log "📦" "Content Coach Installer"

  if [[ "$VERSION" == "latest" ]]; then
    log "🔍" "Fetching latest version..."
    VERSION=$(fetch_latest_tag)
    log "✓" "Latest version: $VERSION"
  fi

  local dmg_name="Content-Coach-${VERSION#v}-arm64.dmg"
  local download_url="https://github.com/$REPO/releases/download/$VERSION/$dmg_name"
  local downloads_dir="$HOME/Downloads"
  local dmg_path="$downloads_dir/$dmg_name"

  log "📥" "Downloading $dmg_name to ~/Downloads..."
  curl -fL --retry 3 --retry-delay 1 -o "$dmg_path" "$download_url"
  log "✓" "Download complete"

  log "🔓" "Removing quarantine attribute..."
  /usr/bin/xattr -cr "$dmg_path" || true

  log "💿" "Opening DMG..."
  open "$dmg_path"

  echo ""
  log "✅" "DMG opened in Finder!"
  log "📂" "Drag Content Coach.app to your Applications folder"
  log "💡" "If updating: quit the running app first, then replace it"
  echo ""
  log "🚀" "After installing, launch from /Applications/Content Coach.app"
}

main "$@"
