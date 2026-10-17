# Omarchy's editor, browser, pager, locale and other shell environment defaults.
source "$OMARCHY_PATH/default/bash/envs"

# History: SHARE_HISTORY also appends new entries as they are entered.
HISTFILE="$ZDOTDIR/.zsh_history"
HISTSIZE=65536
SAVEHIST=32768
setopt append_history share_history
setopt hist_ignore_dups hist_expire_dups_first hist_find_no_dups hist_reduce_blanks
setopt no_beep interactive_comments complete_in_word hist_ignore_space

source "$ZDOTDIR/aliases.zsh"
source "$ZDOTDIR/completion.zsh"
source "$ZDOTDIR/omarchy.zsh"

# Native Zsh activation corresponding to Omarchy's Bash init.
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi
source "$ZDOTDIR/functions.zsh"

# Load the official file/history widgets before plugins wrap ZLE widgets.
if (( $+commands[fzf] )) && [[ -r /usr/share/fzf/key-bindings.zsh ]]; then
  FZF_ALT_C_COMMAND='' source /usr/share/fzf/key-bindings.zsh
fi

# Use the Omarchy/Arch Starship binary, including after migration from Zinit.
if [[ ${TERM:-} != dumb && -x /usr/bin/starship ]]; then
  eval "$(/usr/bin/starship init zsh)"
fi

source "$ZDOTDIR/plugins.zsh"
source "$ZDOTDIR/keybindings.zsh"
