#!/usr/bin/env bash
set -Eeuo pipefail

omarchy-launch-floating-terminal-with-presentation omarchy-remove-preinstalls

omarchy-pkg-add \
    aether \
    cliamp \
    omacut \
    omacalc \
    omawrite

cp "$OMARCHY_PATH"/applications/WhatsApp.desktop ~/.local/share/applications/
cp "$OMARCHY_PATH"/applications/Discord.desktop ~/.local/share/applications/

update-desktop-database ~/.local/share/applications
