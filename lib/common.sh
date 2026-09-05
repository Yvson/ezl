#!/usr/bin/env bash
# common.sh — shared helpers for ezl installer modules

# ----- colors / logging -----------------------------------------------------
if [[ -t 1 ]]; then
    C_RESET="\e[0m"
    C_INFO="\e[34m"
    C_OK="\e[32m"
    C_WARN="\e[33m"
    C_ERR="\e[31m"
else
    C_RESET=""; C_INFO=""; C_OK=""; C_WARN=""; C_ERR=""
fi

log()  { printf "%b[ezl]%b %s\n" "$C_INFO" "$C_RESET" "$*"; }
ok()   { printf "%b[ok]%b  %s\n" "$C_OK"   "$C_RESET" "$*"; }
warn() { printf "%b[warn]%b %s\n" "$C_WARN" "$C_RESET" "$*" >&2; }
err()  { printf "%b[err]%b  %s\n" "$C_ERR" "$C_RESET" "$*" >&2; }
die()  { err "$*"; exit 1; }

# ----- state / idempotency ---------------------------------------------------
EZL_STATE_DIR="${EZL_HOME:-$HOME/.ezl}/.state"
mkdir -p "$EZL_STATE_DIR"

is_done() {
    [[ -f "$EZL_STATE_DIR/$1" ]]
}

mark_done() {
    local name="$1"
    touch "$EZL_STATE_DIR/${name}.done"
}

# ----- system helpers ------------------------------------------------------
have() {
    command -v "$1" >/dev/null 2>&1
}

require_cmd() {
    have "$1" || die "Required command not found: $1"
}

# sudo wrapper: uses sudo if available, otherwise runs directly
as_root() {
    if [[ $EUID -eq 0 ]]; then
        "$@"
    elif have sudo; then
        sudo "$@"
    else
        die "Need root or sudo to run: $*"
    fi
}

ensure_apt_pkgs() {
    local pkgs=("$@")
    local missing=()
    for p in "${pkgs[@]}"; do
        dpkg -s "$p" >/dev/null 2>&1 || missing+=("$p")
    done
    if ((${#missing[@]} > 0)); then
        log "Installing apt packages: ${missing[*]}"
        as_root apt-get update -y
        as_root env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "${missing[@]}"
    else
        ok "Apt packages already present: ${pkgs[*]}"
    fi
}

# add a line to a file if missing
append_if_missing() {
    local file="$1" line="$2"
    mkdir -p "$(dirname "$file")"
    if [[ ! -f "$file" ]] || ! grep -Fxq "$line" "$file"; then
        printf "%s\n" "$line" >> "$file"
    fi
}

# download helper
fetch() {
    local url="$1" dest="$2"
    if have curl; then
        curl -fsSL "$url" -o "$dest"
    elif have wget; then
        wget -qO "$dest" "$url"
    else
        die "Neither curl nor wget available to download $url"
    fi
}
