#!/usr/bin/env bash
# Install Helium and integrate it with Omarchy without overwriting user settings.
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR
. "$SCRIPT_DIR/lib/common.sh"

: "${OMARCHY_PATH:=/usr/share/omarchy}"

readonly HELIUM_PACKAGE='helium-browser-bin'
readonly HELIUM_COMMAND='helium-browser'
readonly HELIUM_DESKTOP='helium.desktop'
readonly CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
readonly HELIUM_PROFILE="$CONFIG_DIR/net.imput.helium"
readonly HELIUM_FLAGS="$CONFIG_DIR/helium-browser-flags.conf"
readonly OMARCHY_FLAGS="$OMARCHY_PATH/config/chromium-flags.conf"
readonly HOST_TEMPLATES="$OMARCHY_PATH/default/chromium/native-messaging-hosts"

skip_install=false
set_default=true
refresh_flags=false

usage() {
  cat <<'HELP'
Usage: install-helium.sh [options]
  --skip-install   Only configure an already installed Helium
  --no-default     Do not change the default browser
  --refresh-flags  Back up and replace existing Helium flags with Omarchy defaults
  -h, --help       Show this help
HELP
}

for option in "$@"; do
  case "$option" in
    --skip-install) skip_install=true ;;
    --no-default) set_default=false ;;
    --refresh-flags) refresh_flags=true ;;
    -h|--help) usage; exit 0 ;;
    *) err "Unknown option: $option"; usage; exit 2 ;;
  esac
done

require_cmd omarchy
require_cmd sed
require_cmd cmp
require_cmd mktemp
require_cmd install
[[ -r "$OMARCHY_FLAGS" ]] || { err "Missing Omarchy flags: $OMARCHY_FLAGS"; exit 1; }

install_native_host() {
  local name="$1" command_path="$2"
  local source="$HOST_TEMPLATES/$name.json"
  local directory="$HELIUM_PROFILE/NativeMessagingHosts"
  local target="$directory/$name.json"
  local temporary

  if [[ ! -r "$source" || ! -x "$command_path" ]]; then
    warn "Skipping native host $name (template or executable missing)"
    return 0
  fi

  mkdir -p "$directory"
  temporary="$(mktemp "$directory/.$name.XXXXXXXX")"

  if ! sed "s|__HOST_PATH__|$command_path|g" "$source" > "$temporary"; then
    rm -f -- "$temporary"
    err "Failed generating native host: $name"
    return 1
  fi

  chmod 0644 "$temporary"
  if cmp -s "$temporary" "$target"; then
    rm -f -- "$temporary"
  else
    mv -f -- "$temporary" "$target"
    log "Configured native host: $name"
  fi
}

if [[ "$skip_install" == false ]]; then
  log 'Installing Helium Browser'
  omarchy pkg aur add "$HELIUM_PACKAGE"
fi
require_cmd "$HELIUM_COMMAND"
[[ -r "/usr/share/applications/$HELIUM_DESKTOP" || -r "${XDG_DATA_HOME:-$HOME/.local/share}/applications/$HELIUM_DESKTOP" ]] || {
  err "Missing desktop entry: $HELIUM_DESKTOP"
  exit 1
}

mkdir -p "$CONFIG_DIR"
if [[ -L "$HELIUM_FLAGS" ]]; then
  warn "Flags path is a symbolic link; leaving it untouched: $HELIUM_FLAGS"
elif [[ ! -e "$HELIUM_FLAGS" ]]; then
  install -m 0644 "$OMARCHY_FLAGS" "$HELIUM_FLAGS"
  log 'Installed Omarchy Chromium flags for Helium'
elif ! cmp -s "$OMARCHY_FLAGS" "$HELIUM_FLAGS"; then
  if [[ "$refresh_flags" == true ]]; then
    backup="$(mktemp "$HELIUM_FLAGS.bak.XXXXXXXX")"
    cp -p -- "$HELIUM_FLAGS" "$backup"
    install -m 0644 "$OMARCHY_FLAGS" "$HELIUM_FLAGS"
    log "Flags refreshed; backup: $backup"
  else
    warn 'Helium flags differ from Omarchy defaults; preserving your settings'
    warn 'Use --refresh-flags to replace them (with backup)'
  fi
else
  log 'Helium flags already up to date'
fi

install_native_host 'com.omarchy.copy_url' "$OMARCHY_PATH/bin/omarchy-chromium-copy-url-host"
install_native_host 'com.omarchy.ytdlp' "$OMARCHY_PATH/bin/omarchy-chromium-ytdlp-host"

if is_cmd omarchy-theme-set-browser; then
  if ! timeout 20s omarchy-theme-set-browser; then
    warn 'Omarchy browser theme could not be applied'
  fi
fi

if [[ "$set_default" == true ]]; then
  require_cmd xdg-settings
  require_cmd xdg-mime
  log 'Setting Helium as the default browser'
  env -u BROWSER xdg-settings set default-web-browser "$HELIUM_DESKTOP"
  xdg-mime default "$HELIUM_DESKTOP" x-scheme-handler/http x-scheme-handler/https

  current="$(env -u BROWSER xdg-settings get default-web-browser)"
  if [[ "$current" != "$HELIUM_DESKTOP" ]]; then
    err "Default browser verification failed: ${current:-unknown}"
    exit 1
  fi
  for scheme in http https; do
    current="$(xdg-mime query default "x-scheme-handler/$scheme")"
    if [[ "$current" != "$HELIUM_DESKTOP" ]]; then
      err "Handler verification failed for $scheme: ${current:-unknown}"
      exit 1
    fi
  done
fi

ok 'Helium Browser is installed and configured'
