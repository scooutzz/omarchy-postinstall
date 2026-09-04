#!/usr/bin/env bash
# Shared helpers for install-*.sh scripts.
# Source this with: . "${SCRIPT_DIR}/lib/common.sh"
#
# Conventions:
#   - Prefer `omarchy` CLI commands over raw pacman/systemctl when available
#     (e.g. `omarchy pkg add`, `omarchy restart`, `omarchy theme set`).
#   - `omarchy pkg add` is idempotent and handles sudo internally.
#   - `is_cmd` is for checking arbitrary binaries, not packages.

log()  { printf '\033[36m==>\033[0m %s\n' "$*"; }
ok()   { printf '\033[32m  ok\033[0m %s\n' "$*"; }
warn() { printf '\033[33mwarn\033[0m %s\n' "$*" >&2; }
err()  { printf '\033[31merr\033[0m  %s\n' "$*" >&2; }

is_cmd() { command -v "$1" >/dev/null 2>&1; }
