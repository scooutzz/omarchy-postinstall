# Every Zsh invocation needs Omarchy's PATH, including non-interactive shells.
# The packaged bootstrap resolves OMARCHY_PATH, including dev-link mode.
[[ -r /usr/share/omarchy/default/bash/env-bootstrap ]] && source /usr/share/omarchy/default/bash/env-bootstrap
