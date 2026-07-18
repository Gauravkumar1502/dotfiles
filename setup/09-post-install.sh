#!/usr/bin/env bash
# Runs optional post-install checks after setup completes.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

test_github_ssh() {
  local output
  local status

  print_info "Testing GitHub SSH connection with: ssh -T git@github.com"
  set +e
  output="$(ssh -T -o StrictHostKeyChecking=accept-new git@github.com 2>&1)"
  status=$?
  set -e

  printf "%s\n" "$output"

  if [[ "$output" == *"successfully authenticated"* ]]; then
    print_success "GitHub SSH authentication looks good."
    return 0
  fi

  print_warn "GitHub SSH test did not report successful authentication. Exit code: $status"
  return 1
}

print_info "Post-install checks:"
prompt_input "Run GitHub SSH connectivity test now? [Y/n]: "
read -r run_test
run_test="${run_test:-Y}"

case "$run_test" in
  [nN]|[nN][oO])
    print_warn "Skipped GitHub SSH connectivity test."
    ;;
  *)
    if ! test_github_ssh; then
      print_warn "You can retry later with: ssh -T git@github.com"
    fi
    ;;
esac

print_success "Post-install checks complete."
