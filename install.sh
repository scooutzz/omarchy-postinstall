#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${HOME:-/root}"

FILES=(
  ".config/hypr/bindings.lua"
  ".config/hypr/input.lua"
  ".config/hypr/looknfeel.lua"
  ".config/foot/foot.ini"
)

echo "==> Installing Omarchy post-install configs into ${TARGET}/"

for rel in "${FILES[@]}"; do
  src="${REPO_DIR}/${rel}"
  dst="${TARGET}/${rel}"

  if [[ ! -f "${src}" ]]; then
    echo "    SKIP (missing in repo): ${rel}"
    continue
  fi

  mkdir -p "$(dirname "${dst}")"

  if [[ -f "${dst}" ]] && ! cmp -s "${src}" "${dst}"; then
    bak="${dst}.bak.$(date +%s)"
    cp "${dst}" "${bak}"
    echo "    backed up: ${rel} -> ${bak}"
  fi

  cp "${src}" "${dst}"
  echo "    installed: ${rel}"
done

if command -v hyprctl >/dev/null 2>&1 && hyprctl version >/dev/null 2>&1; then
  echo "==> Reloading Hyprland..."
  hyprctl reload
else
  echo "==> Hyprland not running; reload it manually to apply changes."
fi

echo "==> Done. Open a new foot window for foot.ini changes to take effect."
