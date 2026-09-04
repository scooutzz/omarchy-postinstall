# ~/.bashrc — Omarchy defaults + ble.sh for vi-mode, syntax highlighting,
# autosuggestions. Tracked in omarchy-postinstall (PARTIAL bash:$HOME).
# Install ble.sh via: omarchy-postinstall/install-ble.sh

# OMARCHY_PATH + PATH adjustments even for non-interactive shells
[[ -r /usr/share/omarchy/default/bash/env-bootstrap ]] && source /usr/share/omarchy/default/bash/env-bootstrap

# Non-interactive shells stop here
[[ $- != *i* ]] && return

# Omarchy defaults: aliases, functions, integrations (mise, starship, zoxide, fzf)
source "$OMARCHY_PATH/default/bash/rc"

# ble.sh (Bash Line Editor: vi-mode, syntax highlighting, autosuggestions)
if [[ -r "$HOME/.local/share/blesh/ble.sh" ]]; then
  source -- "$HOME/.local/share/blesh/ble.sh"
  bleopt default_keymap=vi
fi

# User extras below
