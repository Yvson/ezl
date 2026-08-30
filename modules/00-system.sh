#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=../lib/common.sh
source "$(dirname "$0")/../lib/common.sh"

log "Updating system and installing base build tools"

as_root apt-get update -y
as_root env DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

ensure_apt_pkgs \
    build-essential \
    curl \
    wget \
    unzip \
    zip \
    jq \
    ca-certificates \
    gnupg \
    lsb-release \
    software-properties-common \
    apt-transport-https \
    git \
    vim \
    htop

ok "System base ready"
