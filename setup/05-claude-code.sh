#!/usr/bin/env bash
# Installs Claude Code CLI if missing.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

if command -v claude >/dev/null 2>&1; then
  print_warn "Claude Code CLI already installed, skipping."
  exit 0
fi

print_info "Installing Claude Code CLI..."
curl -fsSL "https://claude.ai/install.sh" | bash
