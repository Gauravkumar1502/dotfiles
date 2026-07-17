#!/usr/bin/env bash
# Stows repository dotfiles into HOME while excluding setup scripts.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Stowing dotfiles into $HOME ..."
stow -vR -t "$HOME" --dir "$REPO_ROOT" --ignore='^setup($|/)' .
