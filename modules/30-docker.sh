#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=../lib/common.sh
source "$(dirname "$0")/../lib/common.sh"
source "$(dirname "$0")/../lib/wsl.sh"
source "$(dirname "$0")/../config/versions.env"

log "Installing native Docker Engine inside WSL"

# ---- systemd required for docker service ------------------------------------
ensure_systemd_in_wslconf

# ---- Docker apt repository --------------------------------------------------
if ! have docker; then
    log "Adding Docker apt repository"
    as_root install -m 0755 -d /etc/apt/keyrings
    fetch "https://download.docker.com/linux/ubuntu/gpg" /tmp/docker.gpg
    as_root gpg --dearmor -o /etc/apt/keyrings/docker.gpg /tmp/docker.gpg 2>/dev/null || true
    as_root chmod a+r /etc/apt/keyrings/docker.gpg

    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
        $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
        as_root tee /etc/apt/sources.list.d/docker.list >/dev/null

    as_root apt-get update -y
    as_root env DEBIAN_FRONTEND=noninteractive apt-get install -y \
        docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
else
    ok "Docker already installed"
fi

# ---- add current user to docker group ----------------------------------------
current_user="${USER:-$(id -un 2>/dev/null || echo root)}"
if ! id -nG "$current_user" | grep -qw docker; then
    log "Adding $current_user to docker group"
    as_root usermod -aG docker "$current_user"
    warn "You need to log out / restart WSL for group change to take effect"
fi

# ---- lazydocker --------------------------------------------------------------
if ! have lazydocker; then
    log "Installing lazydocker $LAZYDOCKER_VERSION"
    tmpdir=$(mktemp -d)
    fetch "https://github.com/jesseduffield/lazydocker/releases/download/v${LAZYDOCKER_VERSION}/lazydocker_${LAZYDOCKER_VERSION}_Linux_x86_64.tar.gz" "$tmpdir/lazydocker.tar.gz"
    tar -xzf "$tmpdir/lazydocker.tar.gz" -C "$tmpdir"
    as_root install -m 0755 "$tmpdir/lazydocker" /usr/local/bin/lazydocker
    rm -rf "$tmpdir"
else
    ok "lazydocker already installed"
fi

wsl_warn_restart
ok "Docker module complete"
