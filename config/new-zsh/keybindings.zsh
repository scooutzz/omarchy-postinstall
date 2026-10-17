# Search history using everything typed before the cursor, like Bash.
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

# Support normal and application-mode arrows in Emacs and Vi keymaps.
for keymap in emacs viins vicmd; do
  bindkey -M "$keymap" '^[[A' up-line-or-beginning-search
  bindkey -M "$keymap" '^[[B' down-line-or-beginning-search
  bindkey -M "$keymap" '^[OA' up-line-or-beginning-search
  bindkey -M "$keymap" '^[OB' down-line-or-beginning-search
  bindkey -M "$keymap" '^K' up-line-or-beginning-search
  bindkey -M "$keymap" '^J' down-line-or-beginning-search
  bindkey -M "$keymap" '^[[Z' reverse-menu-complete
done
unset keymap

# Accept the current autosuggestion.
bindkey '^L' autosuggest-accept

# Edit the current command in the configured editor, then return to the prompt.
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line
