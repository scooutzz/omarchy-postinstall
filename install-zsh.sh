#!/usr/bin/env bash
# Install the lean Zsh configuration without downloading anything at shell startup.
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR
. "$SCRIPT_DIR/lib/common.sh"

skip_deps=false
change_shell=true
for option in "$@"; do
  case "$option" in
    --skip-deps) skip_deps=true ;;
    --no-change-shell) change_shell=false ;;
    -h|--help)
      printf '%s\n' 'Usage: install-newzsh.sh [--skip-deps] [--no-change-shell]'
      printf '%s\n' '  --skip-deps        Only apply config; dependencies must already be installed.'
      printf '%s\n' '  --no-change-shell  Keep the account login shell unchanged.'
      exit 0 ;;
    *) err "Unknown option: $option"; exit 2 ;;
  esac
done

CONFIG_SOURCE="$SCRIPT_DIR/config/new-zsh"
CONFIG_ROOT="${XDG_CONFIG_HOME:-$HOME/.config}"
ZSH_CONFIG="$CONFIG_ROOT/zsh"
ZINIT_ROOT="${XDG_DATA_HOME:-$HOME/.local/share}/zinit"
readonly CONFIG_SOURCE CONFIG_ROOT ZSH_CONFIG ZINIT_ROOT
config_files=(.zshenv .zshrc aliases.zsh completion.zsh functions.zsh keybindings.zsh omarchy.zsh plugins.zsh)

# Validate the source before changing the user's configuration.
for file in home.zshenv "${config_files[@]}"; do
  [[ -r "$CONFIG_SOURCE/$file" ]] || { err "Missing config: $CONFIG_SOURCE/$file"; exit 1; }
done
[[ -r "$SCRIPT_DIR/config/starship/starship.toml" ]] || { err 'Missing Starship config'; exit 1; }
if [[ -L "$ZSH_CONFIG" || ( -e "$ZSH_CONFIG" && ! -d "$ZSH_CONFIG" ) ]]; then
  err "$ZSH_CONFIG must be a real directory so history and cache stay outside the repository."
  exit 1
fi

ensure_checkout() {
  local url="$1" destination="$2" entrypoint="$3"
  if [[ -r "$destination/$entrypoint" ]]; then
    ok "Already installed: ${destination##*/}"
    return
  fi
  mkdir -p "$(dirname "$destination")"
  backup_existing "$destination"
  git clone --depth 1 "$url" "$destination"
  [[ -r "$destination/$entrypoint" ]] || { err "Incomplete checkout: $destination"; return 1; }
}

if [[ $skip_deps == false ]]; then
  require_cmd omarchy
  log 'Ensuring Zsh and its tools are installed'
  omarchy pkg add zsh git starship zoxide fzf bat eza file
  require_cmd git
  ensure_checkout https://github.com/zdharma-continuum/zinit.git "$ZINIT_ROOT/zinit.git" zinit.zsh
  # Zinit owns plugin installation and layout; do not clone plugins separately.
  zsh -dfc '
    typeset -A ZINIT
    ZINIT[HOME_DIR]=$1
    source "$1/zinit.git/zinit.zsh" || exit
    for plugin in zsh-autosuggestions zsh-syntax-highlighting; do
      zinit light "zsh-users/$plugin" || exit
      [[ -r "${ZINIT[PLUGINS_DIR]}/zsh-users---$plugin/$plugin.zsh" ]] || exit 1
    done
  ' install-newzsh "$ZINIT_ROOT"
fi

require_cmd zsh
for file in home.zshenv "${config_files[@]}"; do
  zsh -n "$CONFIG_SOURCE/$file"
done

log 'Linking Zsh configuration'
mkdir -p "$ZSH_CONFIG"
# Import a legacy history only on first install; never replace existing history.
if [[ ! -e "$ZSH_CONFIG/.zsh_history" && -f "$HOME/.zsh_history" ]]; then
  cp -p -- "$HOME/.zsh_history" "$ZSH_CONFIG/.zsh_history"
fi
for file in "${config_files[@]}"; do
  link_path "$CONFIG_SOURCE/$file" "$ZSH_CONFIG/$file"
done
link_path "$CONFIG_SOURCE/home.zshenv" "$HOME/.zshenv"
link_path "$SCRIPT_DIR/config/starship/starship.toml" "$CONFIG_ROOT/starship.toml"

# Change the login shell only after dependencies and configuration are in place.
if [[ $change_shell == true ]]; then
  require_cmd getent
  require_cmd chsh
  user_name="$(id -un)"
  passwd_entry="$(getent passwd "$user_name")"
  [[ -n $passwd_entry ]] || { err "Cannot read account: $user_name"; exit 1; }
  zsh_path="$(command -v zsh)"
  if [[ "${passwd_entry##*:}" != "$zsh_path" ]]; then
    if ! grep -qxF "$zsh_path" /etc/shells; then
      err "$zsh_path is not listed in /etc/shells; check the Zsh package installation."
      exit 1
    fi
    log 'Setting Zsh as the login shell'
    chsh -s "$zsh_path"
  fi
fi

ok 'Zsh ready. Run exec zsh; log out/in if the login shell was changed.'
