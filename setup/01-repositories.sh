#!/usr/bin/env bash
# Configures third-party repositories required by package installation.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

PM="${1:-}"

if [[ -z "$PM" ]]; then
  print_error "Usage: $0 <package-manager>"
  exit 1
fi

configure_dnf_repos() {
  print_info "Installing dnf-plugins-core..."
  sudo dnf install -y dnf-plugins-core

  print_info "Adding Brave repository..."
  sudo dnf config-manager addrepo --overwrite --from-repofile="https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo"

  print_info "Adding VS Code repository..."
  sudo rpm --import "https://packages.microsoft.com/keys/microsoft.asc"
  sudo tee /etc/yum.repos.d/vscode.repo >/dev/null <<'EOF'
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
autorefresh=1
type=rpm-md
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF
}

case "$PM" in
  apt|pacman|paru)
    print_info "No extra repositories configured for $PM."
    ;;
  dnf)
    configure_dnf_repos
    ;;
  *)
    print_error "Unsupported package manager: $PM"
    exit 1
    ;;
esac
