#!/usr/bin/env bash
# Clone zsh plugins into ~/.zsh/plugins/.
set -e
. "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"

DEST="${ZSH_PLUGINS_DIR:-$HOME/.zsh/plugins}"
mkdir -p "$DEST"

clone() {
  local name="$1"
  local dir="$DEST/$name"
  if [[ -d "$dir/.git" ]]; then
    ok "$name already installed"
    return
  fi
  log "Cloning $name..."
  rm -rf "$dir"
  git clone --depth 1 "https://github.com/zsh-users/$name.git" "$dir"
}

clone zsh-autosuggestions
clone zsh-syntax-highlighting
