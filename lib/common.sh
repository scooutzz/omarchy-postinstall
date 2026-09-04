#!/usr/bin/env bash
# Shared helpers for install-*.sh scripts.
# Source this with: . "${SCRIPT_DIR}/lib/common.sh"

log()  { printf '\033[36m==>\033[0m %s\n' "$*"; }
ok()   { printf '\033[32m  ok\033[0m %s\n' "$*"; }
warn() { printf '\033[33mwarn\033[0m %s\n' "$*" >&2; }
err()  { printf '\033[31merr\033[0m  %s\n' "$*" >&2; }

is_cmd()    { command -v "$1" >/dev/null 2>&1; }
pkg_in()    { pacman -Qi "$1" >/dev/null 2>&1; }
pkg_aur()   { pacman -Qm "$1" >/dev/null 2>&1; }

need_root() {
  if (( EUID != 0 )); then
    if ! is_cmd sudo; then
      err "sudo not found and we're not root"
      return 1
    fi
    sudo -v
  fi
}

# Run a command with sudo only if we're not already root.
maybe_sudo() {
  if (( EUID == 0 )); then
    "$@"
  else
    sudo "$@"
  fi
}
