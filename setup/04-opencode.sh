#!/usr/bin/env bash
# Installs OpenCode CLI if missing.
set -euo pipefail

if command -v opencode >/dev/null 2>&1; then
  echo "OpenCode already installed, skipping."
  exit 0
fi

echo "Installing OpenCode..."
curl -fsSL "https://opencode.ai/install" | bash
