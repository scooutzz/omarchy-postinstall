#!/usr/bin/env bash
# Install Helium with Omarchy's Chromium defaults and make it the default browser.
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR
. "$SCRIPT_DIR/lib/common.sh"

: "${OMARCHY_PATH:=/usr/share/omarchy}"

readonly HELIUM_PACKAGE="helium-browser-bin"
readonly HELIUM_COMMAND="helium-browser"
readonly HELIUM_DESKTOP="helium.desktop"
readonly XDG_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
readonly HELIUM_PROFILE_DIR="$XDG_CONFIG_DIR/net.imput.helium"
readonly HELIUM_FLAGS="$XDG_CONFIG_DIR/helium-browser-flags.conf"
readonly OMARCHY_CHROMIUM_FLAGS="$OMARCHY_PATH/config/chromium-flags.conf"
readonly NATIVE_HOST_TEMPLATES="$OMARCHY_PATH/default/chromium/native-messaging-hosts"

require_cmd omarchy
require_cmd sed
require_cmd xdg-settings

install_native_messaging_host() {
  local host_name="$1"
  local host_command="$2"
  local template="$NATIVE_HOST_TEMPLATES/$host_name.json"
  local destination="$HELIUM_PROFILE_DIR/NativeMessagingHosts/$host_name.json"
  local manifest

  [[ -r "$template" ]] || {
    warn "Native messaging template not found: $template"
    return 0
  }
  [[ -x "$host_command" ]] || {
    warn "Native messaging host not found: $host_command"
    return 0
  }

  manifest="$(sed "s|__HOST_PATH__|$host_command|g" "$template")"
  mkdir -p "$(dirname -- "$destination")"
  printf '%s\n' "$manifest" >"$destination"
}

log "Installing Helium Browser"
omarchy pkg aur add "$HELIUM_PACKAGE"
require_cmd "$HELIUM_COMMAND"

[[ -r "$OMARCHY_CHROMIUM_FLAGS" ]] || {
  err "Omarchy Chromium flags not found: $OMARCHY_CHROMIUM_FLAGS"
  exit 1
}

log "Applying Omarchy's Chromium configuration"
mkdir -p "$XDG_CONFIG_DIR"
install -m 0644 "$OMARCHY_CHROMIUM_FLAGS" "$HELIUM_FLAGS"

# Omarchy's flags load these bundled extensions. Helium uses its own profile
# directory, which is not included in Omarchy's Chromium helper list.
install_native_messaging_host \
  com.omarchy.copy_url \
  "$OMARCHY_PATH/bin/omarchy-chromium-copy-url-host"
install_native_messaging_host \
  com.omarchy.ytdlp \
  "$OMARCHY_PATH/bin/omarchy-chromium-ytdlp-host"

if is_cmd omarchy-theme-set-browser; then
  if ! omarchy-theme-set-browser; then
    warn "Helium was installed, but the Omarchy browser theme could not be applied"
  fi
fi

log "Setting Helium as the default browser"
env -u BROWSER xdg-settings set default-web-browser "$HELIUM_DESKTOP"

default_browser="$(env -u BROWSER xdg-settings get default-web-browser)"
if [[ "$default_browser" != "$HELIUM_DESKTOP" ]]; then
  err "Could not set Helium as default (current: ${default_browser:-unknown})"
  exit 1
fi

ok "Helium Browser installed and set as default"
