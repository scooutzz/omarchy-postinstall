# Keep the environment and shell behavior from Omarchy, replacing only the
# Bash-specific interactive layer with its Zsh equivalent.
: "${OMARCHY_PATH:=/usr/share/omarchy}"
[[ -r "$OMARCHY_PATH/default/bash/env-bootstrap" ]] && source "$OMARCHY_PATH/default/bash/env-bootstrap"
[[ -r "$OMARCHY_PATH/default/bash/envs" ]] && source "$OMARCHY_PATH/default/bash/envs"

# History (Bash: histappend, HISTCONTROL=ignoreboth, HISTSIZE=32768)
HISTFILE="$HOME/.zsh_history"
HISTSIZE=32768
SAVEHIST=$HISTSIZE
setopt APPEND_HISTORY INC_APPEND_HISTORY SHARE_HISTORY EXTENDED_HISTORY
setopt HIST_IGNORE_DUPS HIST_IGNORE_SPACE HIST_NO_STORE

# Shell and completion behavior corresponding to Omarchy's shell/inputrc.
setopt AUTO_CD NO_HASH_CMDS INTERACTIVE_COMMENTS NO_BEEP
setopt AUTO_LIST AUTO_MENU COMPLETE_IN_WORD
setopt SH_WORD_SPLIT
LISTMAX=200
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' menu select
zstyle ':completion:*' squeeze-slashes true

# Oh My Zsh. vi-mode ships with OMZ; the other two plugins are installed by
# install-zsh.sh. Syntax highlighting must remain the final plugin.
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""
VI_MODE_RESET_PROMPT_ON_MODE_CHANGE=true
KEYTIMEOUT=20
plugins=(
  vi-mode
  zsh-autosuggestions
  zsh-syntax-highlighting
)

if [[ -r "$ZSH/oh-my-zsh.sh" ]]; then
  source "$ZSH/oh-my-zsh.sh"
else
  print -u2 "warning: Oh My Zsh is not installed; run ~/omarchy-postinstall/install-zsh.sh"
fi

# Prefix-based history search, matching Omarchy's Up/Down behavior in inputrc.
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
for keymap in viins vicmd; do
  bindkey -M "$keymap" '^[[A' up-line-or-beginning-search
  bindkey -M "$keymap" '^[[B' down-line-or-beginning-search
done
unset keymap

# Native Zsh integrations corresponding to Omarchy's Bash init file.
command -v mise >/dev/null && eval "$(mise activate zsh)"
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"
if command -v fzf >/dev/null; then
  [[ -r /usr/share/fzf/completion.zsh ]] && source /usr/share/fzf/completion.zsh
  [[ -r /usr/share/fzf/key-bindings.zsh ]] && source /usr/share/fzf/key-bindings.zsh
fi
[[ ${TERM:-} != dumb ]] && command -v starship >/dev/null && eval "$(starship init zsh)"

# Omarchy's aliases and functions are Zsh-compatible on Omarchy 4.x. Loading
# the installed files keeps this shell aligned when Omarchy updates them.
[[ -r "$OMARCHY_PATH/default/bash/aliases" ]] && source "$OMARCHY_PATH/default/bash/aliases"
for omarchy_function_file in "$OMARCHY_PATH"/default/bash/fns/*(N); do
  [[ -f "$omarchy_function_file" ]] && source "$omarchy_function_file"
done
unset omarchy_function_file

# Two upstream helpers use Bash's zero-based arrays. Run only those helpers
# with KSH_ARRAYS so the rest of the Zsh session keeps native array semantics.
if (( $+functions[hsl] )); then
  functions -c hsl _omarchy_bash_hsl
  hsl() {
    setopt local_options ksh_arrays
    _omarchy_bash_hsl "$@"
  }
fi
if (( $+functions[tsl] )); then
  functions -c tsl _omarchy_bash_tsl
  tsl() {
    setopt local_options ksh_arrays
    _omarchy_bash_tsl "$@"
  }
fi

# These helpers use a directory glob that Bash leaves unmatched. NULL_GLOB is
# scoped to the call so an empty directory behaves the same way in Zsh.
if (( $+functions[hdlm] )); then
  functions -c hdlm _omarchy_bash_hdlm
  hdlm() {
    setopt local_options null_glob
    _omarchy_bash_hdlm "$@"
  }
fi
if (( $+functions[tdlm] )); then
  functions -c tdlm _omarchy_bash_tdlm
  tdlm() {
    setopt local_options null_glob
    _omarchy_bash_tdlm "$@"
  }
fi

# Bash's `read -rp` uses -p for a prompt; in Zsh -p reads from a coprocess.
# Keep the upstream behavior with Zsh's prompt syntax.
if (( $+functions[format-drive] )); then
  format-drive() {
    if (( $# != 2 )); then
      echo "Usage: format-drive <device> <name>"
      echo "Example: format-drive /dev/sda 'My Stuff'"
      echo -e "\nAvailable drives:"
      lsblk -d -o NAME -n | awk '{print "/dev/"$1}'
      return
    fi

    local confirm partition
    echo "WARNING: This will completely erase all data on $1 and label it '$2'."
    read "confirm?Are you sure you want to continue? (y/N): "
    [[ "$confirm" == [Yy] ]] || return 0

    sudo wipefs -a "$1"
    sudo dd if=/dev/zero of="$1" bs=1M count=100 status=progress
    sudo parted -s "$1" mklabel gpt
    sudo parted -s "$1" mkpart primary 1MiB 100%
    sudo parted -s "$1" set 1 msftdata on

    partition="$([[ "$1" == *nvme* ]] && echo "${1}p1" || echo "${1}1")"
    sudo partprobe "$1" || true
    sudo udevadm settle || true
    sudo mkfs.exfat -n "$2" "$partition"

    echo "Drive $1 formatted as exFAT and labeled '$2'."
  }
fi

# Lazy initialization used by Omarchy's Bash setup, with the target shell
# changed to Zsh.
if command -v try >/dev/null; then
  try() {
    unfunction try
    eval "$(SHELL=/bin/zsh command try init "$HOME/Work/tries")"
    try "$@"
  }
fi

# Complete the command hierarchy from the installed omarchy-* executables.
_omarchy() {
  local omarchy_path bin_dir prefix part file rest next
  local -a candidates
  local -A seen
  local -i index

  omarchy_path="${commands[omarchy]:-}"
  [[ -n "$omarchy_path" ]] || return 1
  bin_dir="${omarchy_path:h}"
  prefix=omarchy

  for (( index = 2; index < CURRENT; index++ )); do
    part="${words[index]}"
    [[ -z "$part" || "$part" == -* ]] && continue
    prefix+="-$part"
  done

  for file in "$bin_dir/$prefix"-*(N); do
    [[ -f "$file" && -x "$file" ]] || continue
    rest="${file:t}"
    rest="${rest#${prefix}-}"
    next="${rest%%-*}"
    [[ -n "$next" && -z "${seen[$next]:-}" ]] || continue
    seen[$next]=1
    candidates+=("$next")
  done

  (( CURRENT == 2 )) && candidates+=(commands)
  if [[ "${words[2]:-}" == commands ]]; then
    candidates+=(--all --json --markdown --check)
  fi

  (( ${#candidates[@]} )) && compadd -a candidates
}
(( $+functions[compdef] )) && compdef _omarchy omarchy
