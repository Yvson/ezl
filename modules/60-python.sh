#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=../lib/common.sh
source "$(dirname "$0")/../lib/common.sh"
source "$(dirname "$0")/../config/versions.env"

log "Installing pyenv + Python $PYTHON_VERSION"

# build dependencies for compiling python
ensure_apt_pkgs \
    build-essential libssl-dev zlib1g-dev libbz2-dev \
    libreadline-dev libsqlite3-dev curl libncursesw5-dev \
    xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

if [[ ! -d "$PYENV_ROOT" ]]; then
    log "Installing pyenv"
    curl https://pyenv.run | bash
else
    ok "pyenv already installed"
fi

eval "$(pyenv init -)"

# install latest patch of requested minor version (e.g. 3.12)
latest=$(pyenv install --list | grep -E "^\s*${PYTHON_VERSION}\.[0-9]+$" | tail -1 | tr -d ' ')
if [[ -n "$latest" ]]; then
    pyenv install -s "$latest"
    pyenv global "$latest"
else
    warn "Could not find python ${PYTHON_VERSION}.x in pyenv list"
fi

# pipx for isolated CLI tools
if ! have pipx; then
    ensure_apt_pkgs pipx
    pipx ensurepath
fi

ok "Python module complete"
