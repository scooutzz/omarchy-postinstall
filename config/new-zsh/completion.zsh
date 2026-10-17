# Native completions, including Git subcommands, branches and paths.
autoload -Uz compinit
compinit -d "$ZDOTDIR/.zcompdump"

# Try exact matches first, then ignore case.
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' menu select
zstyle ':completion:*' list-dirs-first true

# Use the installed Omarchy candidate generator for command hierarchy and args.
# Bash evaluates only its completion definitions; Zsh handles matching/display.
_omarchy() {
  local -a candidates
  candidates=("${(@f)$(command bash --noprofile --norc -c '
    source "$OMARCHY_PATH/default/bash/completions" || exit
    COMP_CWORD=$1
    shift
    COMP_WORDS=("$@")
    COMP_WORDS[COMP_CWORD]=""
    _omarchy_complete
    ((${#COMPREPLY[@]})) && printf "%s\n" "${COMPREPLY[@]}"
  ' omarchy-completion "$((CURRENT - 1))" "${words[@]}")}")
  candidates=("${(@)candidates:#}")
  if (( ${#candidates} )); then
    compadd -a candidates
  else
    _files
  fi
}
compdef _omarchy omarchy
