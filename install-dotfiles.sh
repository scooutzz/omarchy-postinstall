#!/usr/bin/env bash
# Stow dotfiles into ~/.config and symlink nvim/ as a whole.
set -e
. "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DST="$HOME/.config"

echo "==> Stowing dotfiles..."
( cd "$REPO_DIR/stow" && stow --adopt -R -t "$DST" omarchy )

# Single symlink for nvim (kept outside the stow package).
if [[ -d "$REPO_DIR/nvim" ]]; then
  if [[ -e "$DST/nvim" && ! -L "$DST/nvim" ]]; then
    mv "$DST/nvim" "$DST/nvim.bak.$(date +%s)"
  fi
  ln -sfn "$REPO_DIR/nvim" "$DST/nvim"
  echo "==> nvim -> $(readlink "$DST/nvim")"
fi

# Apply live changes.
is_cmd hyprctl && hyprctl reload >/dev/null 2>&1 && echo "==> Hyprland reloaded"
tmux has-session 2>/dev/null && tmux source-file "$DST/tmux/tmux.conf" >/dev/null 2>&1 && echo "==> tmux reloaded"
