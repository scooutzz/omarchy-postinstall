#!/usr/bin/env bash
# Run each installer in a separate process, in a deliberate order.
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR
. "$SCRIPT_DIR/lib/common.sh"

INSTALLERS=(
  "remove-preinstalls.sh"
  "install-zsh.sh"
  "install-nvim.sh"
  "install-tmux.sh"
  "install-tailscale.sh"
  "install-bitwarden.sh"
  "install-mongodb-compass.sh"
  "install-helium.sh"
)

for installer in "${INSTALLERS[@]}"; do
  [[ -f "$SCRIPT_DIR/$installer" ]] || {
    err "Installer not found: $SCRIPT_DIR/$installer"
    exit 1
  }

  log "Running $installer"
  if ! bash "$SCRIPT_DIR/$installer"; then
    err "$installer failed"
    exit 1
  fi
done

ok "Post-install completed"
