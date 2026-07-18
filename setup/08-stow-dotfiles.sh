#!/usr/bin/env bash
# Stows repository dotfiles into HOME while excluding setup scripts.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"
IGNORE_PATTERN='^setup($|/)'

print_info "Preview of links that would be removed in unlink step:"
stow -nvD -t "$HOME" --dir "$REPO_ROOT" --ignore="$IGNORE_PATTERN" .

if prompt_confirm "Unlink existing stow-managed symlinks first? [y/N]: "; then
  print_info "Removing currently stowed links from $HOME ..."
  stow -vD -t "$HOME" --dir "$REPO_ROOT" --ignore="$IGNORE_PATTERN" .
else
  print_warn "Skipping unlink step. Continuing with preview and apply flow."
fi

print_info "Previewing stow changes (dry-run)..."
stow -nv -t "$HOME" --dir "$REPO_ROOT" --ignore="$IGNORE_PATTERN" .

if ! prompt_confirm "Apply stow changes now? [y/N]: "; then
  print_warn "Skipped stow apply step by user choice."
  exit 0
fi

print_info "Applying stow changes into $HOME ..."
stow -v -t "$HOME" --dir "$REPO_ROOT" --ignore="$IGNORE_PATTERN" .
print_success "Stow step complete."
