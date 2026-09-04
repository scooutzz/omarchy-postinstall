# Omarchy PATH/OMARCHY_PATH + env (EDITOR, BROWSER, MANPAGER, locale)
: "${OMARCHY_PATH:=/usr/share/omarchy}"
[[ -r "$OMARCHY_PATH/default/bash/env-bootstrap" ]] && source "$OMARCHY_PATH/default/bash/env-bootstrap"
[[ -r "$OMARCHY_PATH/default/bash/envs" ]] && source "$OMARCHY_PATH/default/bash/envs"

# History
HISTSIZE=32768
SAVEHIST=$HISTSIZE
setopt INC_APPEND_HISTORY SHARE_HISTORY EXTENDED_HISTORY \
       HIST_IGNORE_DUPS HIST_IGNORE_SPACE HIST_NO_STORE \
       AUTO_CD NO_HASH_CMDS INTERACTIVE_COMMENTS NO_BEEP

# Oh My Zsh (plugins cloned by install-zsh.sh; NO git plugin, no git aliases)
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(
  zsh-autosuggestions
  zsh-syntax-highlighting
)
source $ZSH/oh-my-zsh.sh

# Integrations: mise, zoxide, fzf (loaded AFTER OMZ)
command -v mise >/dev/null && eval "$(mise activate zsh)"
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"
command -v fzf >/dev/null && {
  [[ -f /usr/share/fzf/key-bindings.zsh ]] && source /usr/share/fzf/key-bindings.zsh
  [[ -f /usr/share/fzf/completion.zsh ]] && source /usr/share/fzf/completion.zsh
}

# Starship prompt (overrides OMZ's theme)
[[ -o interactive ]] && command -v starship >/dev/null && eval "$(starship init zsh)"

# cd via zoxide
command -v zoxide >/dev/null && {
  alias cd='zd'
  zd() {
    if (( $# == 0 )); then
      builtin cd ~ || return
    elif [[ -d $1 ]]; then
      builtin cd "$1" || return
    else
      z "$@" || { echo "Error: Directory not found"; return 1; }
    fi
  }
}

# Aliases (after OMZ so they win; no git aliases by request)
command -v eza >/dev/null && {
  alias ls='eza -lh --group-directories-first --icons=auto'
  alias lsa='ls -a'
  alias lt='eza --tree --level=2 --long --icons --git'
  alias lta='lt -a'
}
command -v fzf >/dev/null && alias ff="fzf --preview 'bat --style=numbers --color=always {}'"
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias a='omarchy-agent --inline'
alias c='opencode --auto'
alias d='docker'
alias t='tmux attach || tmux new -s Work'
alias mup='MISE_MINIMUM_RELEASE_AGE=0 mise up'
n() { [ "$#" -eq 0 ] && command nvim . || command nvim "$@"; }
