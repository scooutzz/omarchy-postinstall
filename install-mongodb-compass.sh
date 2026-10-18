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
readonly QXL_VENDOR_ID="0x1b36"
readonly QXL_DEVICE_ID="0x0100"

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

compass_exec='env MONGODB_COMPASS_TEST_LOG_DIR=/dev/null mongodb-compass --gtk-version=3'

for drm_device in /sys/class/drm/card*/device; do
  [[ -r "$drm_device/vendor" && -r "$drm_device/device" ]] || continue

  read -r vendor_id <"$drm_device/vendor"
  read -r device_id <"$drm_device/device"

  if [[ "$vendor_id" == "$QXL_VENDOR_ID" && "$device_id" == "$QXL_DEVICE_ID" ]]; then
    compass_exec+=' --ozone-platform=x11 --disable-gpu'
    log "QXL virtual GPU detected; using X11 software rendering for MongoDB Compass"
    break
  fi
done

compass_exec+=' --password-store="gnome-libsecret" --ignore-additional-command-line-flags %U'
readonly compass_exec

mkdir -p "$USER_APPLICATIONS_DIR"
temporary_desktop="$(mktemp --tmpdir="$USER_APPLICATIONS_DIR" ".mongodb-compass.XXXXXX.desktop")"

# Keep the working command in a per-user override so package updates do not
# replace it.
awk -v exec_line="$compass_exec" '
  !replaced && /^Exec=/ {
    print "Exec=" exec_line
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
