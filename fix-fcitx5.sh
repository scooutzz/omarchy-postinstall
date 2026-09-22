#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR
. "$SCRIPT_DIR/lib/common.sh"

CONFIG_DIR="$(pwd)/config/fcitx5"
FCITX5_DIR="$HOME/.config/fcitx5/conf/"

link_path "$CONFIG_DIR/keyboard.conf" "FCITX5_DIR/keyboard.conf"

fcitx5-remote -r
