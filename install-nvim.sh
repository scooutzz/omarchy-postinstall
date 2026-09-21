#!/usr/bin/env bash
set -Eeuo pipefail

# Make omarchy-nvim backup
mv ~/.config/nvim ~/.config/omarchy-nvim/

# Clone repo
git clone https://github.com/scooutzz/nvim.git ~/.config
