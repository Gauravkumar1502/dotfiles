#!/usr/bin/env bash
# Stows repository dotfiles into HOME. Setup scripts and other non-dotfile
# paths are excluded via .stow-local-ignore in the repo root, not a flag here.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

print_info "Preview of links that would be removed in unlink step:"
stow -nvD -t "$HOME" --dir "$REPO_ROOT" .

if prompt_confirm "Unlink existing stow-managed symlinks first? [y/N]: "; then
  print_info "Removing currently stowed links from $HOME ..."
  stow -vD -t "$HOME" --dir "$REPO_ROOT" .
else
  print_warn "Skipping unlink step. Continuing with preview and apply flow."
fi

print_info "Previewing stow changes (dry-run)..."
stow -nv -t "$HOME" --dir "$REPO_ROOT" .

if ! prompt_confirm "Apply stow changes now? [y/N]: "; then
  print_warn "Skipped stow apply step by user choice."
  exit 0
fi

print_info "Applying stow changes into $HOME ..."
stow -v -t "$HOME" --dir "$REPO_ROOT" .
print_success "Stow step complete."
