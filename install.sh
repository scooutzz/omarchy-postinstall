#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${HOME:-/root}"
STOW_TARGET="${TARGET}/.config"
PACKAGE="omarchy"

if ! command -v stow >/dev/null 2>&1; then
  echo "stow not found. Install it with: omarchy pkg add stow" >&2
  exit 1
fi

echo "==> Stowing ${PACKAGE} into ${STOW_TARGET}"

# Adopt pre-existing files so stow replaces them with symlinks (instead of skipping).
( cd "${REPO_DIR}/stow" && stow --adopt -R -t "${STOW_TARGET}" "${PACKAGE}" )

echo "==> Symlinks managed by stow:"
( cd "${STOW_TARGET}" && find . -maxdepth 4 -lname "*/stow/${PACKAGE}/*" 2>/dev/null | sort | sed "s|^|    |" )

if command -v hyprctl >/dev/null 2>&1 && hyprctl version >/dev/null 2>&1; then
  echo "==> Reloading Hyprland..."
  hyprctl reload
else
  echo "==> Hyprland not running; reload it manually to apply changes."
fi

if command -v tmux >/dev/null 2>&1 && tmux has-session 2>/dev/null; then
  echo "==> Sourcing new tmux config..."
  tmux source-file "${STOW_TARGET}/tmux/tmux.conf"
else
  echo "==> Tmux not running; new config will apply on next start."
fi

echo "==> Done. Open a new foot window for foot.ini changes to take effect."
