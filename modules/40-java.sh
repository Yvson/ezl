#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=../lib/common.sh
source "$(dirname "$0")/../lib/common.sh"
source "$(dirname "$0")/../config/versions.env"

log "Installing SDKMAN! + Java/Maven/Gradle"

export SDKMAN_DIR="$HOME/.sdkman"

if [[ ! -d "$SDKMAN_DIR" ]]; then
    log "Installing SDKMAN!"
    curl -s "https://get.sdkman.io" | bash
else
    ok "SDKMAN! already installed"
fi

# shellcheck disable=SC1091
[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"

sdk install java "$JAVA_VERSION" </dev/null || warn "Failed to install java $JAVA_VERSION"
sdk install maven "$MAVEN_VERSION" </dev/null || warn "Failed to install maven $MAVEN_VERSION"
sdk install gradle "$GRADLE_VERSION" </dev/null || warn "Failed to install gradle $GRADLE_VERSION"

ok "Java module complete"
