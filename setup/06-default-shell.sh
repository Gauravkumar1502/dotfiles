#!/usr/bin/env bash
# Sets zsh as the default login shell (instead of bash).
set -euo pipefail

ZSH_PATH="$(command -v zsh)"

if [[ -z "$ZSH_PATH" ]]; then
  echo "Error: zsh not found. Install it first." >&2
  exit 1
fi

CURRENT_SHELL="$(getent passwd "$USER" | cut -d: -f7)"

if [[ "$CURRENT_SHELL" == "$ZSH_PATH" ]]; then
  echo "Default shell is already zsh."
else
  echo "Changing default shell to zsh ($ZSH_PATH)..."
  chsh -s "$ZSH_PATH"
  echo
  echo "Default shell changed to zsh. Log out and back in (or reboot) for this to take effect."
fi
