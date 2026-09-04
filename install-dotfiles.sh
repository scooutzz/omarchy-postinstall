#!/usr/bin/env bash
# Stow the dotfiles in stow/omarchy/ into ~/.config/.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
. "${SCRIPT_DIR}/lib/common.sh"

REPO_DIR="${SCRIPT_DIR}"
TARGET="${HOME:-/root}"
STOW_TARGET="${TARGET}/.config"
PACKAGE="omarchy"

is_cmd stow || { err "stow not found. Run ./install-stow.sh first"; exit 1; }

[[ -d "${REPO_DIR}/stow/${PACKAGE}" ]] || { err "Missing stow/${PACKAGE}/ directory"; exit 1; }

log "Stowing ${PACKAGE} into ${STOW_TARGET}"
( cd "${REPO_DIR}/stow" && stow --adopt -R -t "${STOW_TARGET}" "${PACKAGE}" )
ok "Stow complete"

log "Symlinks managed by stow:"
( cd "${STOW_TARGET}" && find . -maxdepth 4 -lname "*/stow/${PACKAGE}/*" 2>/dev/null | sort | sed "s|^|  |" )

if is_cmd hyprctl && hyprctl version >/dev/null 2>&1; then
  log "Reloading Hyprland"
  hyprctl reload
fi

if is_cmd tmux && tmux has-session 2>/dev/null; then
  log "Sourcing new tmux config"
  tmux source-file "${STOW_TARGET}/tmux/tmux.conf"
fi

ok "Done (open a new foot window for foot.ini changes to take effect)"
