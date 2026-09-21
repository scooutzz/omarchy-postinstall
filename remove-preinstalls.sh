#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
. "${SCRIPT_DIR}/lib/common.sh"

# Edite somente estas listas. Deixe uma categoria vazia com: categoria=()
#
# - webapps: use o nome exibido no launcher do Omarchy.
# - apps: use o nome exato do pacote no Arch (consulte com: pacman -Qq).
webapps=(
  "Basecamp"
  "Google Contacts"
  "Google Maps"
  "Google Messages"
  "Google Photos"
  "HEY"
  "X"
  "YouTube"
  "Zoom"
)

apps=(
  "kdenlive"
  "obs-studio"
  "obsidian"
  "pinta"
  "system-config-printer"
)

usage() {
  cat <<EOF
Usage: $(basename -- "$0") [--dry-run]

Remove somente os pre-installs selecionados nas listas no topo do script.

Options:
  --dry-run  Mostra o que seria executado sem remover nada
  -h, --help Mostra esta ajuda
EOF
}

dry_run=false

while (($# > 0)); do
  case "$1" in
    --dry-run)
      dry_run=true
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      err "Unknown option: $1"
      usage >&2
      exit 2
      ;;
  esac
  shift
done

run_command() {
  if "$dry_run"; then
    printf '      '
    printf '%q ' "$@"
    printf '\n'
  else
    "$@"
  fi
}

remove_each() {
  local kind="$1"
  local command_name="$2"
  shift 2

  local item
  for item in "$@"; do
    log "Removing ${kind}: ${item}"
    run_command "$command_name" "$item"
  done
}

selection_count=$((${#webapps[@]} + ${#apps[@]}))

if ((selection_count == 0)); then
  warn "No pre-installs selected. Edit the lists at the top of the script."
  exit 0
fi

# Valide tudo antes de iniciar, evitando uma remoção parcial caso algum comando
# necessário não esteja disponível.
((${#webapps[@]} == 0)) || require_cmd omarchy-webapp-remove
((${#apps[@]} == 0)) || require_cmd omarchy-pkg-drop

# Evita uma notificação gráfica para cada launcher removido. O progresso
# continua sendo mostrado no terminal.
export OMARCHY_REMOVE_NOTIFY=false

remove_each "web app" omarchy-webapp-remove "${webapps[@]}"

if ((${#apps[@]} > 0)); then
  log "Removing packages: ${apps[*]}"
  run_command omarchy-pkg-drop "${apps[@]}"
fi

if "$dry_run"; then
  ok "Dry run complete; nothing was removed."
else
  ok "Selected pre-installs removed."
fi
