#!/usr/bin/env bash
# Entry point: pick a package manager, then run each setup step.
set -euo pipefail

SETUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Select your package manager:"
select PM in apt dnf pacman paru; do
  [[ -n "$PM" ]] && break
  echo "Invalid choice, try again."
done

if ! command -v "$PM" >/dev/null 2>&1; then
  echo "Error: '$PM' is not installed on this system." >&2
  exit 1
fi

"$SETUP_DIR/01-repositories.sh" "$PM"
"$SETUP_DIR/02-packages.sh" "$PM"
"$SETUP_DIR/03-fonts.sh" "$PM"
"$SETUP_DIR/04-opencode.sh"
"$SETUP_DIR/05-zsh-plugins.sh"
"$SETUP_DIR/06-default-shell.sh"
"$SETUP_DIR/07-ssh-setup.sh"
"$SETUP_DIR/08-stow-dotfiles.sh"

echo
echo "Setup complete."
