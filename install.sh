#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${HOME:-/root}"
REPO_PREFIX="config"
TARGET_PREFIX=".config"

FILES=(
  "hypr/bindings.lua"
  "hypr/input.lua"
  "hypr/looknfeel.lua"
  "foot/foot.ini"
  "tmux/tmux.conf"
)

echo "==> Installing Omarchy post-install configs into ${TARGET}/${TARGET_PREFIX}/"

for rel in "${FILES[@]}"; do
  src="${REPO_DIR}/${REPO_PREFIX}/${rel}"
  dst="${TARGET}/${TARGET_PREFIX}/${rel}"

  if [[ ! -f "${src}" ]]; then
    echo "    SKIP (missing in repo): ${REPO_PREFIX}/${rel}"
    continue
  fi

  mkdir -p "$(dirname "${dst}")"

  if [[ -f "${dst}" ]] && ! cmp -s "${src}" "${dst}"; then
    bak="${dst}.bak.$(date +%s)"
    cp "${dst}" "${bak}"
    echo "    backed up: ${TARGET_PREFIX}/${rel} -> ${bak}"
  fi

  cp "${src}" "${dst}"
  echo "    installed: ${TARGET_PREFIX}/${rel}"
done

if command -v hyprctl >/dev/null 2>&1 && hyprctl version >/dev/null 2>&1; then
  echo "==> Reloading Hyprland..."
  hyprctl reload
else
  echo "==> Hyprland not running; reload it manually to apply changes."
fi

if command -v tmux >/dev/null 2>&1 && tmux has-session 2>/dev/null; then
  echo "==> Sourcing new tmux config..."
  tmux source-file "${TARGET}/${TARGET_PREFIX}/tmux/tmux.conf"
else
  echo "==> Tmux not running; new config will apply on next start."
fi

echo "==> Done. Open a new foot window for foot.ini changes to take effect."
