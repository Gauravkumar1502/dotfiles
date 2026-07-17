#!/usr/bin/env bash
# Installs font packages and Nerd Fonts system-wide.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

PM="${1:-}"

if [[ -z "$PM" ]]; then
  print_error "Usage: $0 <package-manager>"
  exit 1
fi

install_font_packages() {
  case "$PM" in
    dnf)
      sudo dnf install -y fira-code-fonts jetbrains-mono-fonts
      ;;
    apt|pacman|paru)
      print_info "No distro font package step configured for $PM."
      ;;
    *)
      print_error "Unsupported package manager: $PM"
      exit 1
      ;;
  esac
}

install_nerd_fonts() {
  local nerd_fonts_root="/usr/local/share/fonts/NerdFonts"
  local font_name
  local tmpdir
  local font_dir
  local font_zip_url

  local font_names=(
    "JetBrainsMono"
    "FiraCode"
  )

  tmpdir="$(mktemp -d)"
  trap '[[ -n "${tmpdir:-}" ]] && rm -rf -- "$tmpdir"' EXIT

  for font_name in "${font_names[@]}"; do
    font_dir="$nerd_fonts_root/$font_name"
    font_zip_url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$font_name.zip"

    if [[ -d "$font_dir" ]] && compgen -G "$font_dir/*.ttf" >/dev/null; then
      print_warn "$font_name Nerd Font already installed in $font_dir."
      continue
    fi

    print_info "Downloading $font_name Nerd Font (latest release)..."
    curl -fsSL "$font_zip_url" -o "$tmpdir/$font_name.zip"

    unzip -qo "$tmpdir/$font_name.zip" -d "$tmpdir/$font_name"
    sudo mkdir -p "$font_dir"
    sudo install -m 0644 "$tmpdir"/$font_name/*.ttf "$font_dir"/
    print_success "Installed $font_name Nerd Font into $font_dir"
  done

  sudo fc-cache -f
}

install_font_packages
install_nerd_fonts
