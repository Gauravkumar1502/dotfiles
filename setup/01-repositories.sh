#!/usr/bin/env bash
# Configures third-party repositories required by package installation.
set -euo pipefail

PM="${1:-}"

if [[ -z "$PM" ]]; then
  echo "Usage: $0 <package-manager>" >&2
  exit 1
fi

configure_dnf_repos() {
  echo "Installing dnf-plugins-core..."
  sudo dnf install -y dnf-plugins-core

  echo "Adding Brave repository..."
  sudo dnf config-manager addrepo --from-repofile="https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo"

  echo "Adding VS Code repository..."
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
    echo "No extra repositories configured for $PM."
    ;;
  dnf)
    configure_dnf_repos
    ;;
  *)
    echo "Unsupported package manager: $PM" >&2
    exit 1
    ;;
esac
