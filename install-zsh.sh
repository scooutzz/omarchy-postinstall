#!/usr/bin/env bash
# Install zsh + Oh My Zsh + the plugins we want, and make zsh the default shell.
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR
. "$SCRIPT_DIR/lib/common.sh"

require_cmd omarchy
require_cmd git
require_cmd id
require_cmd getent

# 1. Install zsh
log "Ensuring zsh is installed"
omarchy pkg add zsh

ZSH_PATH="$(command -v zsh)"
[[ -n "$ZSH_PATH" ]] || {
  err "zsh not found after install"
  exit 1
}
readonly ZSH_PATH

# 2. Set as default shell (skipped if the account already uses it). `$SHELL`
# describes the current process and can remain stale until the next login.
user_name="$(id -un)"
passwd_entry="$(getent passwd "$user_name")"
[[ -n "$passwd_entry" ]] || {
  err "Could not read passwd entry for $user_name"
  exit 1
}
current_shell="${passwd_entry##*:}"

if [[ "$current_shell" != "$ZSH_PATH" ]]; then
  log "Setting zsh as the default shell"
  if ! grep -qxF "$ZSH_PATH" /etc/shells 2>/dev/null; then
    if [[ -w /etc/shells ]]; then
      printf '%s\n' "$ZSH_PATH" >>/etc/shells
    else
      require_cmd sudo
      printf '%s\n' "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null
    fi
  fi

  require_cmd chsh
  chsh -s "$ZSH_PATH"
  ok "Default shell changed to zsh (log out/in to apply)"
else
  ok "zsh is already the default shell"
fi

# 3. Clone Oh My Zsh if missing
OMZ_DIR="$HOME/.oh-my-zsh"
readonly OMZ_DIR
if [[ -d "$OMZ_DIR/.git" ]]; then
  ok "Oh My Zsh already installed"
else
  backup_existing "$OMZ_DIR"
  log "Cloning Oh My Zsh"
  git clone --depth 1 https://github.com/ohmyzsh/ohmyzsh.git "$OMZ_DIR"
fi

# 4. Clone OMZ plugins we want into ~/.oh-my-zsh/custom/plugins/
OMZ_CUSTOM="${ZSH_CUSTOM:-$OMZ_DIR/custom}/plugins"
mkdir -p "$OMZ_CUSTOM"

clone_omz_plugin() {
  local name="$1"
  local dir="$OMZ_CUSTOM/$name"
  if [[ -d "$dir/.git" ]]; then
    ok "OMZ plugin $name already installed"
    return
  fi

  backup_existing "$dir"
  log "Cloning OMZ plugin $name"
  git clone --depth 1 "https://github.com/zsh-users/$name.git" "$dir"
}

clone_omz_plugin zsh-autosuggestions
clone_omz_plugin zsh-syntax-highlighting

CONFIG_DIR="$(pwd)/config"

# Link zsh
ln -sf "$CONFIG_DIR/zsh/.zshenv" "$HOME"
ln -sf "$CONFIG_DIR/zsh/.zshrc" "$HOME"

# Link starship
link_path "$CONFIG_DIR/starship/starship.toml" "$HOME/.config/starship.toml"

ok "zsh ready"
