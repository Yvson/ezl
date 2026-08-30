#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=../lib/common.sh
source "$(dirname "$0")/../lib/common.sh"
source "$(dirname "$0")/../lib/wsl.sh"

log "Installing Git and GitHub CLI"

# Git is installed in 00-system, but ensure it again for standalone module runs
ensure_apt_pkgs git

# ---- GitHub CLI from official apt repo --------------------------------------
if ! have gh; then
    log "Adding GitHub CLI apt repository"
    keyring_dir="/usr/share/keyrings"
    keyring="$keyring_dir/githubcli-archive-keyring.gpg"
    as_root mkdir -p -m 755 "$keyring_dir"
    if [[ ! -f "$keyring" ]]; then
        fetch "https://cli.github.com/packages/githubcli-archive-keyring.gpg" /tmp/githubcli.gpg
        as_root install -m 644 /tmp/githubcli.gpg "$keyring"
    fi
    echo "deb [arch=$(dpkg --print-architecture) signed-by=$keyring] https://cli.github.com/packages stable main" | as_root tee /etc/apt/sources.list.d/github-cli.list >/dev/null
    as_root apt-get update -y
    as_root env DEBIAN_FRONTEND=noninteractive apt-get install -y gh
else
    ok "GitHub CLI already installed"
fi

# ---- install gitconfig template if one doesn't exist -------------------------
if [[ ! -f "$HOME/.gitconfig" ]]; then
    cp "$(dirname "$0")/../config/gitconfig" "$HOME/.gitconfig"
    ok "Installed $HOME/.gitconfig template. Edit name/email inside."
else
    ok "$HOME/.gitconfig already exists, leaving untouched"
fi

ok "Git module complete"
