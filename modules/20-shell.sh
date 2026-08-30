#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=../lib/common.sh
source "$(dirname "$0")/../lib/common.sh"

log "Setting up zsh, oh-my-zsh, plugins, and tmux"

ensure_apt_pkgs zsh tmux

# ---- oh-my-zsh ---------------------------------------------------------------
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    log "Installing oh-my-zsh"
    export RUNZSH=no CHSH=no KEEP_ZSHRC=yes
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    ok "oh-my-zsh already installed"
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# ---- plugins -----------------------------------------------------------------
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
    log "Installing zsh-autosuggestions"
    git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
    log "Installing zsh-syntax-highlighting"
    git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

# ---- install our zshrc (overwrite omz default, but backup existing) ----------
if [[ ! -f "$HOME/.zshrc.bcx-backup" ]]; then
    [[ -f "$HOME/.zshrc" ]] && cp "$HOME/.zshrc" "$HOME/.zshrc.bcx-backup"
fi
cp "$(dirname "$0")/../config/zshrc" "$HOME/.zshrc"
cp "$(dirname "$0")/../config/tmux.conf" "$HOME/.tmux.conf"

# ---- change default shell to zsh ---------------------------------------------
# Skip chsh in containers / CI where it's not meaningful and can hang
if [[ -z "${CI:-}" && -z "${GITHUB_ACTIONS:-}" && ! -f /.dockerenv ]]; then
    if [[ "$SHELL" != *zsh ]]; then
        log "Changing default shell to zsh (may ask for password)"
        if have chsh; then
            chsh -s "$(command -v zsh)"
        else
            warn "chsh not available; run: sudo chsh -s $(command -v zsh) $USER"
        fi
    else
        ok "Default shell is already zsh"
    fi
else
    log "Skipping chsh (container/CI environment)"
fi

ok "Shell module complete"
