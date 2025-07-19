# My Dotfiles

This repository contains my personal configuration files managed with GNU Stow.

## Usage

To install all configurations:

```bash
cd ~/dotfiles
stow .
```

To remove configurations:

```bash
stow -D .
```

To update after making changes:

```bash
stow -R .
```

## Structure

This dotfiles repository follows the same directory structure as the home directory, allowing for easy management with `stow .`.

### Currently Managed Configurations

- **Shell**: `.zshrc` (Zsh with Oh My Zsh and Powerlevel10k)
- **Powerlevel10k**: `.p10k.zsh` (theme configuration)
- **Git**: `.gitconfig` (Git configuration with user settings)
- **Terminal**: `kitty/` (Kitty terminal emulator configuration)

## Adding New Configurations

1. Create the same directory structure as in your home directory
2. Copy your config files to the corresponding location in dotfiles
3. Remove the original files from your home directory
4. Run `stow .` to create symlinks

Example:

```bash
# For a new app config
cp ~/.config/newapp/config.conf ~/dotfiles/.config/newapp/
rm ~/.config/newapp/config.conf
cd ~/dotfiles && stow .
```

## Features

✅ **One-command installation**: Just run `stow .`  
✅ **Automatic symlink management**: Stow handles all the linking  
✅ **Version controlled**: All configs are tracked in git  
✅ **Easy updates**: Changes in dotfiles automatically reflect in your system

## Notes

- Files that shouldn't be version controlled (like histories, logs, caches) are excluded via `.gitignore`
- Sensitive files should be handled separately or encrypted
- Always backup your existing configs before stowing
