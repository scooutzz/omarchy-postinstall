#!/usr/bin/env bash
# Install zsh + Oh My Zsh + the plugins we want, and make zsh the default shell.
set -e
. "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"

# 1. Install zsh
echo "==> Ensuring zsh is installed..."
omarchy pkg add zsh

ZSH_PATH="$(command -v zsh)"
[[ -n "$ZSH_PATH" ]] || { err "zsh not found after install"; exit 1; }

# 2. Set as default shell (skipped if already so)
if [[ "$SHELL" != "$ZSH_PATH" ]]; then
  echo "==> Setting zsh as default shell..."
  grep -qxF "$ZSH_PATH" /etc/shells 2>/dev/null || \
    echo "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null
  chsh -s "$ZSH_PATH"
  ok "Default shell changed to zsh (log out/in to apply)"
fi

# 3. Clone Oh My Zsh if missing
if [[ ! -d "$HOME/.oh-my-zsh/.git" ]]; then
  echo "==> Cloning Oh My Zsh..."
  git clone --depth 1 https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
fi

# 4. Clone OMZ plugins we want into ~/.oh-my-zsh/custom/plugins/
OMZ_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"
mkdir -p "$OMZ_CUSTOM"

clone_omz_plugin() {
  local name="$1"
  local dir="$OMZ_CUSTOM/$name"
  if [[ -d "$dir/.git" ]]; then
    ok "OMZ plugin $name already installed"
    return
  fi
  log "Cloning OMZ plugin $name..."
  rm -rf "$dir"
  git clone --depth 1 "https://github.com/zsh-users/$name.git" "$dir"
}

clone_omz_plugin zsh-autosuggestions
clone_omz_plugin zsh-syntax-highlighting

ok "zsh + OMZ + plugins ready"
