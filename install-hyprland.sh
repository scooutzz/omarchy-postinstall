#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR
. "$SCRIPT_DIR/lib/common.sh"

CONFIG_DIR="$(pwd)/config/hypr"
HYPR_DIR="$HOME/.config/hypr"

link_path "$CONFIG_DIR/bindings.lua" "$HYPR_DIR/bindings.lua"
link_path "$CONFIG_DIR/input.lua" "$HYPR_DIR/input.lua"
link_path "$CONFIG_DIR/looknfeel.lua" "$HYPR_DIR/looknfeel.lua"

hyprctl reload
