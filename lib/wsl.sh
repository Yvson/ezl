#!/usr/bin/env bash
# wsl.sh — WSL-specific helpers

# source common.sh if not already loaded (guard against re-entry state pollution)
if [[ -z "${C_RESET:-}" ]]; then
    # shellcheck source=lib/common.sh
    [[ -f "${BASH_SOURCE%/*}/common.sh" ]] && source "${BASH_SOURCE%/*}/common.sh"
fi

is_wsl() {
    grep -qi microsoft /proc/version 2>/dev/null
}

wsl_version() {
    if [[ -r /proc/version ]]; then
        grep -qi "wsl2" /proc/version && echo "2" || echo "1"
    else
        echo "unknown"
    fi
}

# Ensure /etc/wsl.conf has [boot] systemd=true
ensure_systemd_in_wslconf() {
    local conf="/etc/wsl.conf"
    if [[ ! -f "$conf" ]] || ! grep -Pq '^\s*systemd\s*=\s*true\s*$' "$conf"; then
        log "Enabling systemd in $conf (requires 'wsl --shutdown' from Windows)"
        as_root mkdir -p "$(dirname "$conf")"
        as_root bash -c "cat <<'EOF' >> $conf

[boot]
systemd=true
EOF"
    else
        ok "systemd already enabled in $conf"
    fi
}

wsl_warn_restart() {
    if is_wsl; then
        warn "You must run 'wsl --shutdown' from PowerShell/Windows Terminal, then restart Ubuntu for changes to take effect."
    fi
}
