# Sourced for every zsh invocation (interactive or not).
# This is where the Omarchy PATH/OMARCHY_PATH bootstrap goes, so non-interactive
# shells (scripts, ssh commands, mise) still find /usr/share/omarchy on PATH.

: "${OMARCHY_PATH:=/usr/share/omarchy}"
[[ -r "$OMARCHY_PATH/default/bash/env-bootstrap" ]] && source "$OMARCHY_PATH/default/bash/env-bootstrap"
