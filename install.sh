#!/usr/bin/env bash
# Run every install-*.sh in this repo, in order.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=lib/common.sh
. "${SCRIPT_DIR}/lib/common.sh"

STEPS=(
  install-stow.sh
  install-dotfiles.sh
  # install-tailscale.sh
  # install-helium.sh
)

for step in "${STEPS[@]}"; do
  path="${SCRIPT_DIR}/${step}"
  if [[ ! -f "${path}" ]]; then
    warn "Skipping missing step: ${step}"
    continue
  fi
  log "==> ${step%.sh}"
  . "${path}"
done

ok "All steps finished."
