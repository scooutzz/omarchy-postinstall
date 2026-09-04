# ============================================================
# Omarchy zsh config: brings over everything Omarchy ships in
# /usr/share/omarchy/default/bash/ plus keeps Oh My Zsh on top.
# OMZ is loaded first; Omarchy aliases override last so they win.
# ============================================================

# ---- Environment ----
: "${OMARCHY_PATH:=/usr/share/omarchy}"
[[ -r "$OMARCHY_PATH/default/bash/env-bootstrap" ]] && source "$OMARCHY_PATH/default/bash/env-bootstrap"
[[ -r "$OMARCHY_PATH/default/bash/envs" ]] && source "$OMARCHY_PATH/default/bash/envs"

# ---- History (Omarchy defaults: 32768 lines, append, dedupe) ----
HISTSIZE=32768
SAVEHIST=$HISTSIZE
setopt INC_APPEND_HISTORY SHARE_HISTORY EXTENDED_HISTORY
setopt HIST_IGNORE_DUPS HIST_IGNORE_SPACE HIST_NO_STORE

# ---- Misc shell opts ----
setopt AUTO_CD              # type a dirname to cd into it
setopt NO_HASH_CMDS         # for mise (same role as bash's `set +h`)
setopt INTERACTIVE_COMMENTS # allow # comments in interactive
setopt NO_BEEP

# ---- Completion ----
autoload -U compinit
compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/compdump"

# ---- Omarchy functions (mostly bash-compatible; sourced from fns/*) ----
for f in "$OMARCHY_PATH"/default/bash/fns/*; do source "$f"; done

# ---- Integrations (zsh variants) ----
if command -v mise &>/dev/null; then
  eval "$(mise activate zsh)"
fi

if command -v zoxide &>/dev/null; then
  eval "$(zoxide init zsh)"
fi

if command -v fzf &>/dev/null; then
  [[ -f /usr/share/fzf/key-bindings.zsh ]] && source /usr/share/fzf/key-bindings.zsh
  [[ -f /usr/share/fzf/completion.zsh ]] && source /usr/share/fzf/completion.zsh
fi

# ---- Oh My Zsh (loaded before starship so the prompt gets overridden) ----
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(
  git
  vi-mode
  history
  # zsh-autosuggestions       # install: git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
  # zsh-syntax-highlighting   # install: git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
)
source $ZSH/oh-my-zsh.sh

# ---- Starship prompt (last so it overrides OMZ's theme) ----
if [[ -o interactive ]] && command -v starship &>/dev/null; then
  eval "$(starship init zsh)"
fi

# ---- Omarchy aliases (defined AFTER OMZ so they win) ----
if command -v eza &>/dev/null; then
  alias ls='eza -lh --group-directories-first --icons=auto'
  alias lsa='ls -a'
  alias lt='eza --tree --level=2 --long --icons --git'
  alias lta='lt -a'
fi

# fzf with bat preview (and kitty icat for images when in kitty)
if [[ "$TERM" == "xterm-kitty" ]]; then
  alias ff="fzf --preview 'case \$(file --mime-type -b {}) in image/*) kitty icat --clear --transfer-mode=memory --stdin=no --place=\${FZF_PREVIEW_COLUMNS}x\${FZF_PREVIEW_LINES}@0x0 {} ;; *) bat --style=numbers --color=always {} ;; esac'"
else
  alias ff="fzf --preview 'bat --style=numbers --color=always {}'"
fi
alias eff='$EDITOR "$(ff)"'

# cd with zoxide wrapper
if command -v zoxide &>/dev/null; then
  alias cd='zd'
  zd() {
    if (( $# == 0 )); then
      builtin cd ~ || return
    elif [[ -d $1 ]]; then
      builtin cd "$1" || return
    else
      if ! z "$@"; then
        echo "Error: Directory not found"
        return 1
      fi
    fi
  }
fi

# open: detached xdg-open
open() { xdg-open "$@" >/dev/null 2>&1 & }

# Directory navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Tools
alias a='omarchy-agent --inline'
alias c='opencode --auto'
alias cx='printf "\033[2J\033[3J\033[H" && claude --permission-mode auto'
alias cy='codex --approve-for-me'
alias d='docker'
alias r='rails'
alias t='tmux attach || tmux new -s Work'
alias h='herdr'
alias ic='tdl c'
alias ix='tdl cx'
alias icx='tdl c cx'
alias mup='MISE_MINIMUM_RELEASE_AGE=0 mise up'

# nvim: open current dir if no args
n() { if [ "$#" -eq 0 ]; then command nvim . ; else command nvim "$@"; fi; }

# Git (Omarchy takes precedence over OMZ git plugin)
# Unalias OMZ's versions so Omarchy's functions (ga, gd from fns/worktrees)
# and our simpler aliases (gcm, gcad) win.
unalias g gcm gcad 2>/dev/null
unalias ga gd 2>/dev/null   # remove OMZ alias shadow; ga/gd are Omarchy fns now
alias g='git'
alias gcm='git commit -m'
alias gcam='git commit -a -m'
alias gcad='git commit --amend'

# ---- User extras below ----
