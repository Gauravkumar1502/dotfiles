#!/usr/bin/env bash
# Shared helpers for setup scripts.

if [[ "${FORCE_COLOR:-0}" == "1" || -t 1 ]]; then
  COLOR_GREEN='\033[0;32m'
  COLOR_YELLOW='\033[1;33m'
  COLOR_CYAN='\033[0;36m'
  COLOR_RED='\033[0;31m'
  COLOR_RESET='\033[0m'
else
  COLOR_GREEN=''
  COLOR_YELLOW=''
  COLOR_CYAN=''
  COLOR_RED=''
  COLOR_RESET=''
fi

print_info() {
  printf "%b\n" "${COLOR_CYAN}$1${COLOR_RESET}"
}

print_warn() {
  printf "%b\n" "${COLOR_YELLOW}$1${COLOR_RESET}"
}

print_success() {
  printf "%b\n" "${COLOR_GREEN}$1${COLOR_RESET}"
}

print_error() {
  printf "%b\n" "${COLOR_RED}$1${COLOR_RESET}" >&2
}

print_key() {
  printf "%b\n" "${COLOR_GREEN}$1${COLOR_RESET}"
}

prompt_input() {
  printf "%b" "${COLOR_CYAN}$1${COLOR_RESET}"
}

prompt_confirm() {
  local prompt="${1:-Proceed? [y/N]: }"
  local answer

  prompt_input "$prompt"
  read -r answer || return 1
  case "$answer" in
    [yY]|[yY][eE][sS])
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}
