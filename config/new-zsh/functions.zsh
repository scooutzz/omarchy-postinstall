# File picker with the same preview as Omarchy's Bash.
ff() {
  local preview='bat --style=numbers --color=always -- {}'
  if [[ $TERM == xterm-kitty ]] && (( $+commands[kitty] )); then
    preview='case $(file --mime-type -b -- {}) in image/*) kitty icat --clear --transfer-mode=memory --stdin=no --place=${FZF_PREVIEW_COLUMNS}x${FZF_PREVIEW_LINES}@0x0 {} ;; *) bat --style=numbers --color=always -- {} ;; esac'
  fi
  command fzf --preview "$preview" "$@"
}

# Open the selection in EDITOR; cancelling leaves the editor closed.
eff() {
  local selected editor_command="${EDITOR:-omarchy-launch-editor --inline}"
  local -a editor_words
  selected=$(ff "$@" --no-multi) || return
  [[ -n $selected ]] || return 0
  # Support editor arguments and quoted paths without evaluating shell code.
  editor_words=(${(z)editor_command})
  editor_words=("${(@Q)editor_words}")
  command "${editor_words[@]}" "$selected"
}

# Keep cd=z, with the same arrow rules as Omarchy's zd helper.
if (( $+commands[zoxide] )); then
  z() {
    if (( $# == 0 )) || [[ -d $1 ]]; then
      __zoxide_z "$@"
    else
      if ! __zoxide_z "$@"; then
        print -r -- 'Error: Directory not found'
        return 1
      fi
      printf '\U000F17A9 %s\n' "$PWD"
    fi
  }
  alias cd='z'
fi

# Create one directory (including parents) and enter it through zoxide.
mkcd() {
  if (( $# != 1 )); then
    print -u2 -- 'Usage: mkcd <directory>'
    return 1
  fi
  command mkdir -p -- "$1" && z "${1:a}"
}
