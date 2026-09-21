#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR
. "$SCRIPT_DIR/lib/common.sh"

HYPR_DIR="$(pwd)/config/hypr"

link_path "$HYPR_DIR/bindings.lua" "$HOME/.config/bindings.lua"
link_path "$HYPR_DIR/input.lua" "$HOME/.config/input.lua"
link_path "$HYPR_DIR/looknfell.lua" "$HOME/.config/looknfell.lua"
