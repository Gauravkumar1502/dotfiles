#!/usr/bin/env bash
# Installs packages for the given package manager. Package lists live below in
# one associative array: key = package manager, value = space-separated packages
# (bash assoc-array values are scalars, so a list is just a string we split later).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

declare -A PACKAGES=(
  [apt]="git curl unzip zsh stow kitty neovim sway waybar dunst fzf bat ripgrep fd-find rofi grim slurp wl-clipboard cliphist"
  [dnf]="git curl unzip zsh stow kitty neovim sway waybar dunst fzf bat ripgrep fd-find fastfetch rofi grim slurp wl-clipboard cliphist code brave-browser"
  [pacman]="git curl unzip zsh stow kitty neovim sway waybar dunst fzf bat ripgrep fd rofi grim slurp wl-clipboard cliphist"
  [paru]="git curl unzip zsh stow kitty neovim sway waybar dunst fzf bat ripgrep fd rofi grim slurp wl-clipboard cliphist"
)

PM="${1:-}"

if [[ -z "$PM" || -z "${PACKAGES[$PM]+x}" ]]; then
  print_error "Usage: $0 <${!PACKAGES[*]}>"
  exit 1
fi

read -ra PKGS <<< "${PACKAGES[$PM]}"

print_info "Installing packages with $PM: ${PKGS[*]}"

case "$PM" in
  apt)
    sudo apt update
    sudo apt install -y "${PKGS[@]}"
    ;;
  dnf)
    sudo dnf install -y "${PKGS[@]}"
    ;;
  pacman)
    sudo pacman -Syu --needed --noconfirm "${PKGS[@]}"
    ;;
  paru)
    paru -Syu --needed --noconfirm "${PKGS[@]}"
    ;;
esac
