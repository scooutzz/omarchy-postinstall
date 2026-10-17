#!/usr/bin/env bash

set -Eeuo pipefail

omarchy-launch-floating-terminal-with-presentation 'omarchy-install-browser brave-origin'

omarchy-default-browser brave-origin
