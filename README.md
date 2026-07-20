# My Dotfiles

This repository contains my personal configuration files managed with GNU Stow.

## Usage

Always run Stow with an explicit target directory (`-t "$HOME"`) so links are created in your home directory.
This repo keeps setup scripts under `setup/`, which are excluded from Stow operations via the
`.stow-local-ignore` file in the repo root (no need to pass `--ignore` on the command line).

Clone and enter the repo first:

```bash
git clone https://github.com/Gauravkumar1502/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

1. Preview first (conflict check, no filesystem changes):

```bash
cd ~/dotfiles
stow -nvR -t "$HOME" .
```

2. Install/update symlinks after preview looks correct:

```bash
stow -vR -t "$HOME" .
```

3. Remove symlinks managed by this repo:

```bash
stow -vD -t "$HOME" .
```

Flags used:

- `-n`: dry-run mode (test only)
- `-v`: verbose output
- `-R`: restow (relink/update)
- `-D`: delete/unlink stowed symlinks
- `-t "$HOME"`: target directory for links

`.stow-local-ignore` replaces Stow's built-in default ignore list (Stow uses one or the other,
never both), so it also replicates those defaults (`.git`, `README.*`, editor backup files, etc.)
in addition to excluding `setup/`. Add new exclusion patterns there, not as a CLI flag.

## Structure

This dotfiles repository follows the same directory structure as the home directory, allowing for easy management with `stow -t "$HOME" .`.

### Currently Managed Configurations

- **Shell**: `.zshrc` (Zsh with Oh My Zsh and Powerlevel10k)
- **Powerlevel10k**: `.p10k.zsh` (theme configuration)
- **Git**: `.gitconfig` (Git configuration with user settings)
- **SSH**: `.ssh/config` (SSH host aliases and key paths)
- **Kitty**: `.config/kitty/` (terminal config and theme include)
- **Neovim**: `.config/nvim/` (LazyVim-based Neovim configuration)
- **Sway**: `.config/sway/` (window manager config and environment)
- **Waybar**: `.config/waybar/` (status bar config and styling)
- **Dunst**: `.config/dunst/` (notification daemon config)

## Adding New Configurations

1. Create the same directory structure as in your home directory
2. Copy your config files to the corresponding location in dotfiles
3. Remove the original files from your home directory
4. Preview with `stow -nvR -t "$HOME" .`, then run `stow -vR -t "$HOME" .`

## Notes

- Files that shouldn't be version controlled (like histories, logs, caches) are excluded via `.gitignore`
- Sensitive files should be handled separately or encrypted
- Always backup your existing configs before stowing
- Avoid `--adopt` unless you explicitly want Stow to move local files into this repo
