#!/usr/bin/env bash
set -Eeuo pipefail

NVIM_DIR="$HOME/.config/nvim"
BACKUP_DIR="$HOME/.config/omarchy-nvim"

if [ -d "$NVIM_DIR" ]; then
    if [ -d "$BACKUP_DIR" ]; then
        rm -rf "$NVIM_DIR"
    else
        mkdir -p "$(dirname "$BACKUP_DIR")"
        mv "$NVIM_DIR" "$BACKUP_DIR"
    fi
fi

git clone https://github.com/scooutzz/nvim.git "$NVIM_DIR"
