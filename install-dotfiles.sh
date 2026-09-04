#!/usr/bin/env bash
# Link config/<app>/ into ~/.config/<app>/.
# Whole-folder symlink by default; PARTIAL apps get per-file symlinks
# so Omarchy's default files in ~/.config/<app>/ are left untouched.
set -e
. "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DST="$HOME/.config"

# Apps with only partial overrides tracked in the repo (Omarchy owns the rest).
# Add new ones here when you only want to track a few files for that app.
PARTIAL=(hypr)

[[ -d "$REPO_DIR/config" ]] || { err "Missing $REPO_DIR/config/"; exit 1; }

echo "==> Linking dotfiles into $DST"

for app_dir in "$REPO_DIR"/config/*/; do
  app="$(basename "$app_dir")"
  dst_app="$DST/$app"

  if [[ " ${PARTIAL[*]} " == *" $app "* ]]; then
    # Per-file symlinks: leave existing files in ~/.config/<app>/ alone
    mkdir -p "$dst_app"
    while IFS= read -r -d '' f; do
      rel="${f#"$app_dir"}"
      rel="${rel#/}"
      dst_file="$dst_app/$rel"
      if [[ -e "$dst_file" && ! -L "$dst_file" ]]; then
        mv "$dst_file" "$dst_file.bak.$(date +%s)"
      fi
      ln -sfn "$f" "$dst_file"
    done < <(find "$app_dir" -type f -print0)
    echo "    $app: per-file symlinks"
  else
    # Whole-folder symlink: one link for the whole config
    if [[ -e "$dst_app" && ! -L "$dst_app" ]]; then
      mv "$dst_app" "$dst_app.bak.$(date +%s)"
    fi
    ln -sfn "$app_dir" "$dst_app"
    echo "    $app -> $app_dir"
  fi
done

is_cmd hyprctl && hyprctl reload >/dev/null 2>&1 && echo "==> Hyprland reloaded"
tmux has-session 2>/dev/null && tmux source-file "$DST/tmux/tmux.conf" >/dev/null 2>&1 && echo "==> tmux reloaded"
