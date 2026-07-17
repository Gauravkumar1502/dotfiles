#!/usr/bin/env bash
# Generates a GitHub SSH key at the path used by .ssh/config, then prints the public key.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

KEY_PATH="$HOME/.ssh/githubSSH"

mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

choose_ssh_algorithm() {
  local choice

  print_info "Choose SSH key algorithm:"
  printf "1) ed25519 (Recommended)\n"
  printf "2) rsa-4096\n"

  while true; do
    prompt_input "Select algorithm [1]: "
    read -r choice
    choice="${choice:-1}"
    case "$choice" in
      1)
        SSH_ALGORITHM="ed25519"
        return 0
        ;;
      2)
        SSH_ALGORITHM="rsa-4096"
        return 0
        ;;
      *)
        print_warn "Invalid choice. Enter 1 or 2."
        ;;
    esac
  done
}

generate_ssh_key() {
  default_email="$(git config --global user.email 2>/dev/null || true)"
  prompt_input "Email/comment for the GitHub SSH key [${default_email:-none}]: "
  read -r email
  email="${email:-$default_email}"

  choose_ssh_algorithm

  print_info "Generating SSH key for GitHub at $KEY_PATH"
  print_info "ssh-keygen will now ask you to set a passphrase (press Enter twice for no passphrase)."

  case "$SSH_ALGORITHM" in
    ed25519)
      ssh-keygen -t ed25519 -C "$email" -f "$KEY_PATH"
      ;;
    rsa-4096)
      ssh-keygen -t rsa -b 4096 -C "$email" -f "$KEY_PATH"
      ;;
  esac
}

if [[ -f "$KEY_PATH" ]]; then
  print_warn "SSH key already exists at $KEY_PATH"
  print_info "Choose action:"
  printf "1) Skip key generation (Recommended)\n"
  printf "2) Replace existing key\n"

  while true; do
    prompt_input "Select action [1]: "
    read -r action_choice
    action_choice="${action_choice:-1}"

    case "$action_choice" in
      1)
        print_warn "Keeping existing SSH key."
        break
        ;;
      2)
        print_warn "Replacing existing SSH key at $KEY_PATH"
        rm -f "$KEY_PATH" "$KEY_PATH.pub"
        generate_ssh_key
        break
        ;;
      *)
        print_warn "Invalid choice. Enter 1 or 2."
        ;;
    esac
  done
else
  generate_ssh_key
fi

echo
print_info "Public key (add/update this in your GitHub profile: https://github.com/settings/keys):"
echo
while IFS= read -r line; do
  print_key "$line"
done < "$KEY_PATH.pub"
echo
