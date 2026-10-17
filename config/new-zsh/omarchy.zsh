# Compression is already compatible with Zsh.
source "$OMARCHY_PATH/default/bash/fns/compression"

# Run these self-contained helpers from the installed originals. Bash preserves
# read -rp, argv/substring semantics, SSH retries and signal handling exactly.
# No Bash startup files are loaded; exported Zsh environment is inherited.
_omarchy_bash_function() {
  command bash --noprofile --norc -c '
    module=$1
    shift
    if [[ $module == ssh-port-forwarding ]]; then
      source "$OMARCHY_PATH/default/bash/fns/ssh-reconnect" || exit
    fi
    source "$OMARCHY_PATH/default/bash/fns/$module" || exit
    "$@"
  ' omarchy-zsh "$@"
}

iso2sd()       { _omarchy_bash_function drives iso2sd "$@"; }
format-drive() { _omarchy_bash_function drives format-drive "$@"; }
ssh()         { _omarchy_bash_function ssh-reconnect ssh "$@"; }
fip()         { _omarchy_bash_function ssh-port-forwarding fip "$@"; }
dip()         { _omarchy_bash_function ssh-port-forwarding dip "$@"; }
lip()         { _omarchy_bash_function ssh-port-forwarding lip "$@"; }
