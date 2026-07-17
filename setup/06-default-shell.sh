#!/usr/bin/env bash
# Sets zsh as the default login shell (instead of bash).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

ZSH_PATH="$(command -v zsh)"

if [[ -z "$ZSH_PATH" ]]; then
  print_error "Error: zsh not found. Install it first."
  exit 1
fi

CURRENT_SHELL="$(getent passwd "$USER" | cut -d: -f7)"

if [[ "$CURRENT_SHELL" == "$ZSH_PATH" ]]; then
  print_warn "Default shell is already zsh."
else
  print_info "Changing default shell to zsh ($ZSH_PATH)..."
  chsh -s "$ZSH_PATH"
  echo
  print_success "Default shell changed to zsh. Log out and back in (or reboot) for this to take effect."
fi
