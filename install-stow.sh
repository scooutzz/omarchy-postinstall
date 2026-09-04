#!/usr/bin/env bash
. "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"

echo "==> Installing stow..."
omarchy pkg add stow
