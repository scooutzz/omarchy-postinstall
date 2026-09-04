#!/usr/bin/env bash
# Install zsh and make it the default login shell.
set -e
. "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"

echo "==> Ensuring zsh is installed..."
omarchy pkg add zsh

ZSH_PATH="$(command -v zsh)"
[[ -n "$ZSH_PATH" ]] || { err "zsh not found after install"; exit 1; }

if [[ "$SHELL" == "$ZSH_PATH" ]]; then
  ok "zsh is already your default shell"
  exit 0
fi

echo "==> Setting zsh as default shell..."
grep -qxF "$ZSH_PATH" /etc/shells 2>/dev/null || \
  echo "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null

chsh -s "$ZSH_PATH"
ok "Default shell changed to zsh (log out and back in to apply)"
