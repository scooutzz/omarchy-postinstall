#!/usr/bin/env bash
# Install GNU Stow if missing.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
. "${SCRIPT_DIR}/lib/common.sh"

log "Ensuring stow is installed..."
omarchy pkg add stow
ok "stow ready"
