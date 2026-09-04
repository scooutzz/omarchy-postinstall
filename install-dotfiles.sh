#!/usr/bin/env bash
# Stow the config/ package into ~/.config/.
set -e
. "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DST="$HOME/.config"

[[ -d "$REPO_DIR/config" ]] || { err "Missing $REPO_DIR/config/"; exit 1; }

echo "==> Stowing dotfiles into $DST"
( cd "$REPO_DIR" && stow --no-folding --adopt -R -t "$DST" config )

is_cmd hyprctl && hyprctl reload >/dev/null 2>&1 && echo "==> Hyprland reloaded"
tmux has-session 2>/dev/null && tmux source-file "$DST/tmux/tmux.conf" >/dev/null 2>&1 && echo "==> tmux reloaded"
