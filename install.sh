#!/usr/bin/env bash
# Run every install-*.sh in this repo, in order.
set -e
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. "$DIR/install-dotfiles.sh"
# . "$DIR/install-tailscale.sh"
# . "$DIR/install-helium.sh"
