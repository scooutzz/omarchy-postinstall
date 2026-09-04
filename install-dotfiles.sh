#!/usr/bin/env bash
# Link config/<app>/ into ~/.config/<app>/.
# Whole-folder symlink by default; PARTIAL apps get per-file symlinks
# so Omarchy's default files in ~/.config/<app>/ are left untouched.
set -e
. "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DST="$HOME/.config"

# Apps with only partial overrides tracked in the repo (Omarchy owns the rest).
# Format: "app"        -> files go under $HOME/.config/<app>/
#         "app:target" -> files go under <target>/ (use for apps whose config
#                          lives outside ~/.config, like zsh at ~/.zshrc)
PARTIAL=(
  "hypr"
  "bash:$HOME"
  "zsh:$HOME"
)

[[ -d "$REPO_DIR/config" ]] || { err "Missing $REPO_DIR/config/"; exit 1; }

echo "==> Linking dotfiles"

for app_dir in "$REPO_DIR"/config/*/; do
  app="$(basename "$app_dir")"

  # Find matching PARTIAL entry (may have a ":target" suffix)
  partial_target=""
  for entry in "${PARTIAL[@]}"; do
    if [[ "${entry%%:*}" == "$app" ]]; then
      partial_target="${entry#*:}"
      [[ "$partial_target" == "$entry" ]] && partial_target="$DST/$app"
      break
    fi
  done

  if [[ -n "$partial_target" ]]; then
    # Per-file symlinks under the configured target dir
    mkdir -p "$partial_target"
    while IFS= read -r -d '' f; do
      rel="${f#"$app_dir"}"
      rel="${rel#/}"
      dst_file="$partial_target/$rel"
      if [[ -e "$dst_file" && ! -L "$dst_file" ]]; then
        mv "$dst_file" "$dst_file.bak.$(date +%s)"
      fi
      ln -sfn "$f" "$dst_file"
    done < <(find "$app_dir" -type f -print0)
    echo "    $app: per-file -> $partial_target/"
  else
    # Whole-folder symlink under $DST/<app>
    dst_app="$DST/$app"
    if [[ -e "$dst_app" && ! -L "$dst_app" ]]; then
      mv "$dst_app" "$dst_app.bak.$(date +%s)"
    fi
    ln -sfn "$app_dir" "$dst_app"
    echo "    $app -> $app_dir"
  fi
done

is_cmd hyprctl && hyprctl reload >/dev/null 2>&1 && echo "==> Hyprland reloaded"
tmux has-session 2>/dev/null && tmux source-file "$DST/tmux/tmux.conf" >/dev/null 2>&1 && echo "==> tmux reloaded"
