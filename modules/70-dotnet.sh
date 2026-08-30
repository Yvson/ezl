#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=../lib/common.sh
source "$(dirname "$0")/../lib/common.sh"
source "$(dirname "$0")/../config/versions.env"

log "Installing .NET SDK (channel: $DOTNET_CHANNEL)"

export DOTNET_ROOT="$HOME/.dotnet"

if [[ ! -d "$DOTNET_ROOT" ]]; then
    mkdir -p "$DOTNET_ROOT"
    fetch "https://dot.net/v1/dotnet-install.sh" /tmp/dotnet-install.sh
    bash /tmp/dotnet-install.sh --channel "$DOTNET_CHANNEL" --install-dir "$DOTNET_ROOT"
else
    ok ".NET already installed, checking for updates"
    fetch "https://dot.net/v1/dotnet-install.sh" /tmp/dotnet-install.sh
    bash /tmp/dotnet-install.sh --channel "$DOTNET_CHANNEL" --install-dir "$DOTNET_ROOT"
fi

# PATH is handled in config/zshrc

ok ".NET module complete"
