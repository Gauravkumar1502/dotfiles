#!/usr/bin/env bash
# Installs Oh My Zsh (if missing) and clones the plugin/theme repos used by .zshrc / .p10k.zsh.
set -euo pipefail

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  echo "Installing Oh My Zsh..."
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# name|git url|type(plugins|themes) -- mirrors plugins=(...) and ZSH_THEME in .zshrc
PLUGIN_REPOS=(
  "zsh-autosuggestions|https://github.com/zsh-users/zsh-autosuggestions|plugins"
  "zsh-syntax-highlighting|https://github.com/zsh-users/zsh-syntax-highlighting|plugins"
  "fast-syntax-highlighting|https://github.com/zdharma-continuum/fast-syntax-highlighting|plugins"
  "zsh-autocomplete|https://github.com/marlonrichert/zsh-autocomplete|plugins"
  "powerlevel10k|https://github.com/romkatv/powerlevel10k|themes"
)

for entry in "${PLUGIN_REPOS[@]}"; do
  IFS='|' read -r name url type <<< "$entry"
  target="$ZSH_CUSTOM/$type/$name"
  if [[ -d "$target" ]]; then
    echo "$name already present, skipping."
  else
    echo "Cloning $name..."
    git clone --depth=1 "$url" "$target"
  fi
done
