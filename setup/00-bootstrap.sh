#!/usr/bin/env bash
# Entry point: pick a package manager, then run each setup step.
set -euo pipefail

SETUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ -z "${SETUP_LOG_INITIALIZED:-}" && "${SETUP_NO_LOG:-0}" != "1" ]]; then
  timestamp="$(date +%F-%H%M%S)"
  export SETUP_LOG_FILE="${SETUP_LOG_FILE:-$HOME/setup-bootstrap-$timestamp.log}"
  export SETUP_LOG_INITIALIZED=1
  export FORCE_COLOR="${FORCE_COLOR:-1}"
  exec > >(tee -a "$SETUP_LOG_FILE") 2>&1
fi

source "$SETUP_DIR/common.sh"

if [[ -n "${SETUP_LOG_FILE:-}" ]]; then
  print_info "Logging bootstrap output to $SETUP_LOG_FILE"
fi

print_info "Select your package manager:"
select PM in apt dnf pacman paru; do
  [[ -n "$PM" ]] && break
  print_warn "Invalid choice, try again."
done

if ! command -v "$PM" >/dev/null 2>&1; then
  print_error "Error: '$PM' is not installed on this system."
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
print_success "Setup complete."
