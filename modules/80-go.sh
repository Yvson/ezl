#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=../lib/common.sh
source "$(dirname "$0")/../lib/common.sh"
source "$(dirname "$0")/../config/versions.env"

log "Installing Go $GO_VERSION"

arch="$(dpkg --print-architecture)"
case "$arch" in
    amd64) goarch="amd64" ;;
    arm64) goarch="arm64" ;;
    *) die "Unsupported architecture: $arch" ;;
esac

if [[ -d /usr/local/go ]]; then
    as_root rm -rf /usr/local/go
fi

fetch "https://go.dev/dl/go${GO_VERSION}.linux-${goarch}.tar.gz" /tmp/go.tar.gz
as_root tar -C /usr/local -xzf /tmp/go.tar.gz
rm /tmp/go.tar.gz

# PATH is handled in config/zshrc

ok "Go module complete"
