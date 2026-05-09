## Project

Dotfiles managed with GNU Stow. Each top-level directory is a stow package.

## Structure

- Packages targeting `$HOME`: shell, zsh, git, vim, tools, ssh, fonts, macos, linux, freebsd, xmonad
- Packages targeting `$HOME/.config`: ghostty, gh, gh-dash, lazygit, sesh, zed, omniwm, borders, sketchybar, starship, tmux, tmuxinator, worktrunk
- `karabiner/` is not stowed (build based workflow)
- `bin/` is not stowed (added to PATH via .exports)
- `install.sh` is the entry point

## Commands

```shell
# Install all packages
./install.sh

# Stow a single package
stow --target="$HOME" <package>
stow --target="$HOME/.config" <package>

# Unstow
stow -D --target="$HOME" <package>

# Dry run
stow -nv --target="$HOME" <package>
```

## Conventions

- Use `git mv` when moving files to preserve history
- Never commit secrets (API keys, tokens, credentials)
- Stow ignores `.gitignore` files by default. Global gitignore is handled via copy in install.sh.
