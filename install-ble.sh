#!/usr/bin/env bash
# Install ble.sh (Bash Line Editor) — gives bash vi-mode, syntax highlighting,
# and autosuggestions. Built from source and installed to ~/.local/share/blesh/.
set -e
. "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"

DEST="$HOME/.local/share/blesh"
REPO="https://github.com/akinomyoga/ble.sh.git"

if [[ -r "$DEST/ble.sh" ]]; then
  ok "ble.sh already installed at $DEST"
  exit 0
fi

for cmd in git make gawk; do
  is_cmd "$cmd" || omarchy pkg add "$cmd"
done

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

log "Cloning ble.sh..."
git clone --recursive --depth 1 --shallow-submodules "$REPO" "$tmp/ble.sh"

log "Building and installing ble.sh to $DEST..."
make -C "$tmp/ble.sh" install PREFIX="$HOME/.local"

ok "ble.sh installed"
echo "    Open a new bash shell to pick it up. To enable vi-mode, add to your .bashrc:"
echo "      [[ -r \"$DEST/ble.sh\" ]] && source -- \"$DEST/ble.sh\" && bleopt edit_mode=vi"
