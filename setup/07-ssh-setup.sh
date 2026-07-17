#!/usr/bin/env bash
# Generates a GitHub SSH key at the path used by .ssh/config, then prints the public key.
set -euo pipefail

KEY_PATH="$HOME/.ssh/githubSSH"

mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

if [[ -f "$KEY_PATH" ]]; then
  echo "SSH key already exists at $KEY_PATH, skipping generation."
else
  default_email="$(git config --global user.email 2>/dev/null || true)"
  read -rp "Email/comment for the GitHub SSH key [${default_email:-none}]: " email
  email="${email:-$default_email}"

  echo "Generating SSH key for GitHub at $KEY_PATH"
  echo "ssh-keygen will now ask you to set a passphrase (press Enter twice for no passphrase)."
  ssh-keygen -t ed25519 -C "$email" -f "$KEY_PATH"
fi

echo
echo "Public key (add/update this in your GitHub profile: https://github.com/settings/keys):"
echo
cat "$KEY_PATH.pub"
echo
