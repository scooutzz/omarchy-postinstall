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

require_cmd() {
  local command_name="$1"

  if ! is_cmd "$command_name"; then
    err "Required command not found: $command_name"
    return 1
  fi
}

# Move an existing path aside without overwriting an older backup. This also
# handles dangling symlinks, for which `-e` alone returns false.
backup_existing() {
  local path="$1"
  local backup counter

  [[ -e "$path" || -L "$path" ]] || return 0

  backup="${path}.bak.$(date +%Y%m%d-%H%M%S)"
  counter=1
  while [[ -e "$backup" || -L "$backup" ]]; do
    backup="${path}.bak.$(date +%Y%m%d-%H%M%S).$counter"
    ((counter += 1))
  done

  mv -- "$path" "$backup"
  warn "Backed up $path to $backup"
}

# Create an idempotent symlink. A correct link is left untouched; any other
# file, directory, or link is backed up first.
link_path() {
  local source_path="${1%/}"
  local destination="$2"
  local current_target=""

  [[ -L "$destination" ]] && current_target="$(readlink -- "$destination")"
  if [[ "${current_target%/}" == "$source_path" ]]; then
    return 0
  fi

  mkdir -p "$(dirname -- "$destination")"
  backup_existing "$destination"
  ln -s -- "$source_path" "$destination"
}
