#!/usr/bin/env bash
# Install GNU Stow if missing.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
. "${SCRIPT_DIR}/lib/common.sh"

if pkg_in stow; then
  ok "stow already installed"
else
  log "Installing stow..."
  maybe_sudo pacman -S --noconfirm --needed stow
  ok "stow installed"
fi
