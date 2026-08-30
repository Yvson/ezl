#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=../lib/common.sh
source "$(dirname "$0")/../lib/common.sh"

log "Installing extra CLI tools"

ensure_apt_pkgs \
    fzf \
    ripgrep \
    bat \
    htop \
    tree \
    direnv \
    httpie \
    tldr \
    btop \
    ncdu

# some distros name the bat binary 'batcat'
if have batcat && ! have bat; then
    mkdir -p "$HOME/.local/bin"
    ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"
fi

ok "Extras module complete"
