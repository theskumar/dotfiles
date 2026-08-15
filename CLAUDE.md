## Project

Dotfiles managed with GNU Stow. Each top-level directory is a stow package.

## Structure

- Packages targeting `$HOME`: shell, zsh, git, vim, tools, ssh, fonts, macos, linux, freebsd, xmonad
- Packages targeting `$HOME/.config`: ghostty, gh, gh-dash, lazygit, mise, sesh, zed, omniwm, starship, tmux, tmuxinator, worktrunk
- `karabiner/` targets `$HOME/.config` (plain JSON, no build step)
- `bin/` is not stowed (added to PATH via .exports)
- `brew-manage/` is a git submodule: `Brewfile` (declarative Homebrew package source) + analysis tools symlinked into `bin/` (`brew-info`, `brew-deps-graph`)
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

- Use `git mv` to move files and keep history
- Never commit secrets (API keys, tokens, credentials)
- Stow ignores `.gitignore` files by default. `install.sh` copies the global gitignore.

## Homebrew packages

- Edit the package list in `brew-manage/Brewfile` (the submodule), not in `setup/setup_mac.sh`.
- `setup/setup_mac.sh` runs `brew bundle --file=brew-manage/Brewfile`, then handles non-brew installs (bun, `npm -g`, `gh` extensions).
- Commit Brewfile changes inside the submodule and push to `theskumar/brew-manage`, then record the new submodule pointer in this repo.
