#!/usr/bin/env bash
# Install MongoDB Compass and configure its application launcher.
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR
. "$SCRIPT_DIR/lib/common.sh"

readonly COMPASS_PACKAGE="mongodb-compass-bin"
readonly COMPASS_COMMAND="mongodb-compass"
readonly COMPASS_DESKTOP="mongodb-compass.desktop"
readonly SYSTEM_DESKTOP="/usr/share/applications/$COMPASS_DESKTOP"
readonly USER_APPLICATIONS_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
readonly USER_DESKTOP="$USER_APPLICATIONS_DIR/$COMPASS_DESKTOP"

temporary_desktop=""

cleanup() {
  [[ -z "$temporary_desktop" ]] || rm -f -- "$temporary_desktop"
}
trap cleanup EXIT

require_cmd omarchy
require_cmd awk
require_cmd install

log "Installing MongoDB Compass"
omarchy pkg aur add "$COMPASS_PACKAGE"

require_cmd "$COMPASS_COMMAND"

if [[ ! -r "$SYSTEM_DESKTOP" ]]; then
  err "MongoDB Compass desktop launcher not found: $SYSTEM_DESKTOP"
  exit 1
fi

mkdir -p "$USER_APPLICATIONS_DIR"
temporary_desktop="$(mktemp --tmpdir="$USER_APPLICATIONS_DIR" ".mongodb-compass.XXXXXX.desktop")"

# Keep the working command in a per-user override so package updates do not
# replace it.
awk '
  !replaced && /^Exec=/ {
    print "Exec=mongodb-compass --password-store=\"gnome-libsecret\" --ignore-additional-command-line-flags %U"
    replaced = 1
    next
  }
  { print }
  END { if (!replaced) exit 1 }
' "$SYSTEM_DESKTOP" >"$temporary_desktop"

if is_cmd desktop-file-validate; then
  if ! validation_output="$(desktop-file-validate "$temporary_desktop" 2>&1)"; then
    err "Generated MongoDB Compass launcher is invalid"
    printf '%s\n' "$validation_output" >&2
    exit 1
  fi
fi

install -m 0644 "$temporary_desktop" "$USER_DESKTOP"

if is_cmd update-desktop-database; then
  update-desktop-database "$USER_APPLICATIONS_DIR"
fi

ok "MongoDB Compass installed and application launcher configured"
