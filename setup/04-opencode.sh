#!/usr/bin/env bash
# Installs OpenCode CLI if missing.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

if command -v opencode >/dev/null 2>&1; then
  print_warn "OpenCode already installed, skipping."
  exit 0
fi

print_info "Installing OpenCode..."
curl -fsSL "https://opencode.ai/install" | bash
