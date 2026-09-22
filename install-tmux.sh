#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR
. "$SCRIPT_DIR/lib/common.sh"

CONFIG_DIR="$(pwd)/config/tmux"
TMUX_DIR="$HOME/.config/tmux"

# Install TMUX
omarchy pkg aur add tmux

TPM_DIR="$HOME/.tmux/plugins/tpm"

# Check if TPM is already installed
if [ -d "$TPM_DIR" ]; then
  echo "TPM is already installed in $TPM_DIR"
else
  echo "Installing Tmux Plugin Manager (TPM)..."
  git clone https://github.com/tmux-plugins/tpm $TPM_DIR
  echo "TPM installed successfully!"
fi

link_path "$CONFIG_DIR" "$TMUX_DIR"
rm -rf ~/.config/tmux/plugins
$HOME/.tmux/plugins/tpm/bin/install_plugins
