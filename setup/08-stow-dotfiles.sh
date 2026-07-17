#!/usr/bin/env bash
# Stows repository dotfiles into HOME while excluding setup scripts.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"
IGNORE_PATTERN='^setup($|/)'

print_info "Removing currently stowed links from $HOME ..."
stow -vD -t "$HOME" --dir "$REPO_ROOT" --ignore="$IGNORE_PATTERN" .

print_info "Previewing stow changes (dry-run)..."
stow -nvR -t "$HOME" --dir "$REPO_ROOT" --ignore="$IGNORE_PATTERN" .

if ! prompt_confirm "Apply stow changes now? [y/N]: "; then
  print_warn "Skipped stow apply step by user choice."
  exit 0
fi

print_info "Applying stow changes into $HOME ..."
stow -vR -t "$HOME" --dir "$REPO_ROOT" --ignore="$IGNORE_PATTERN" .
print_success "Stow step complete."
