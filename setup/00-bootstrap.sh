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

run_step() {
  local step_no="$1"
  local step_name="$2"
  shift 2

  echo
  print_info "[$step_no/$TOTAL_STEPS] $step_name"
  "$@"
  print_success "[$step_no/$TOTAL_STEPS] $step_name done"
}

TOTAL_STEPS=11

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

run_step 1 "Configure repositories" "$SETUP_DIR/01-repositories.sh" "$PM"
run_step 2 "Install packages" "$SETUP_DIR/02-packages.sh" "$PM"
run_step 3 "Install fonts" "$SETUP_DIR/03-fonts.sh" "$PM"
run_step 4 "Install OpenCode" "$SETUP_DIR/04-opencode.sh"
run_step 5 "Install Claude Code CLI" "$SETUP_DIR/05-claude-code.sh"
run_step 6 "Install zsh plugins" "$SETUP_DIR/05-zsh-plugins.sh"
run_step 7 "Install SDKMAN tools" "$SETUP_DIR/06-sdkman.sh"
run_step 8 "Set default shell" "$SETUP_DIR/06-default-shell.sh"
run_step 9 "Set up SSH key" "$SETUP_DIR/07-ssh-setup.sh"
run_step 10 "Stow dotfiles" "$SETUP_DIR/08-stow-dotfiles.sh"

echo
print_success "Main setup steps complete (10/10)."
print_info "Completed: repos, packages, fonts, opencode, claude code, zsh plugins, sdkman tools, shell, ssh, stow."
echo
print_info "Starting post-install checks..."

run_step 11 "Post-install checks" "$SETUP_DIR/09-post-install.sh"

echo
print_success "Setup complete."
