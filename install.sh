#!/usr/bin/env bash
# install.sh — one-line bootstrap for a WSL Ubuntu 24.04 dev environment
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/<owner>/bcx/main/install.sh | bash
#   ./install.sh [--only module1,module2] [--skip module1,module2] [--list] [--dry-run] [--force] [--yes]
#
set -euo pipefail

# --- location of this script (works when executed from curl too) -------------
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" >/dev/null 2>&1 && pwd -P)"
# When run via curl|bash, BASH_SOURCE is "bash" → fall back to repo URL
if [[ ! -d "$SCRIPT_DIR/lib" ]]; then
    SCRIPT_DIR=""
fi

REPO_URL="https://github.com/Yvson/bcx.git"
BCX_HOME="${BCX_HOME:-$HOME/.bcx}"

# --- minimal argparse (store args early for possible re-exec) ----------------
ORIG_ARGS=("$@")

DRY_RUN=0
FORCE=0
ASSUME_YES=0
LIST_ONLY=0
ONLY_LIST=""
SKIP_LIST=""

usage() {
    cat <<EOF
Usage: $0 [OPTIONS]

Options:
  --only LIST     comma-separated list of modules to run (e.g. 00-system,10-git)
  --skip LIST     comma-separated list of modules to skip
  --list          list available modules and exit
  --dry-run       print what would be done
  --force         ignore state and re-run modules
  -y, --yes       non-interactive mode (assume yes to prompts)
  -h, --help      show this help
EOF
}

while (($# > 0)); do
    case "$1" in
        --only)   ONLY_LIST="$2"; shift 2 ;;
        --skip)   SKIP_LIST="$2"; shift 2 ;;
        --list)   LIST_ONLY=1; shift ;;
        --dry-run) DRY_RUN=1; shift ;;
        --force)  FORCE=1; shift ;;
        -y|--yes) ASSUME_YES=1; shift ;;
        -h|--help) usage; exit 0 ;;
        *) echo "Unknown option: $1" >&2; usage; exit 1 ;;
    esac
done

# --- clone or update repo if running from curl --------------------------------
if [[ -z "$SCRIPT_DIR" || ! -f "$SCRIPT_DIR/install.sh" ]]; then
    if ! command -v git >/dev/null 2>&1; then
        apt-get update -y && apt-get install -y git
    fi
    if [[ -d "$BCX_HOME" ]]; then
        git -C "$BCX_HOME" pull --ff-only
    else
        git clone "$REPO_URL" "$BCX_HOME"
    fi
    SCRIPT_DIR="$BCX_HOME"
    cd "$SCRIPT_DIR"
    exec ./install.sh "${ORIG_ARGS[@]}"
fi

# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/wsl.sh"

# --- module runner ------------------------------------------------------------
MODULES_DIR="$SCRIPT_DIR/modules"

list_modules() {
    find "$MODULES_DIR" -maxdepth 1 -name '*.sh' | sort | while read -r f; do
        basename "$f" .sh
    done
}

should_run() {
    local mod="$1"
    [[ -n "$ONLY_LIST" ]] && [[ ",$ONLY_LIST," != *",$mod,"* ]] && return 1
    [[ -n "$SKIP_LIST" ]] && [[ ",$SKIP_LIST," == *",$mod,"* ]] && return 1
    return 0
}

if (( LIST_ONLY )); then
    list_modules
    exit 0
fi

# --- environment checks -------------------------------------------------------
if ! grep -qi "Ubuntu" /etc/os-release 2>/dev/null; then
    warn "This script targets Ubuntu 24.04. Proceed, but some steps may fail."
fi

if ! is_wsl; then
    warn "Not running inside WSL. Docker/systemd steps may not apply."
fi

if (( ASSUME_YES == 0 && DRY_RUN == 0 )); then
    read -rp "Install bcx dev environment to $BCX_HOME? [y/N] " ans
    [[ "$ans" =~ ^[Yy]$ ]] || { log "Aborted."; exit 0; }
fi

for module_file in "$MODULES_DIR"/*.sh; do
    mod="$(basename "$module_file" .sh)"
    should_run "$mod" || { log "Skipping $mod (--skip/--only)"; continue; }

    if is_done "$mod" && (( FORCE == 0 )); then
        ok "$mod already completed (use --force to re-run)"
        continue
    fi

    log "Running module: $mod"
    if (( DRY_RUN )); then
        echo "  would run: bash $module_file"
    else
        bash "$module_file"
        mark_done "$mod"
    fi
done

ok "All requested modules finished."
if is_wsl; then
    wsl_warn_restart
fi
