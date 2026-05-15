dotfiles
========

My dotfiles, managed with [GNU Stow](https://www.gnu.org/software/stow/).

A `.stowrc` at the repo root sets `--target=~` by default, so most `stow` commands work without an explicit `--target` flag.

## Setup

### Prerequisites

Install Stow:

```shell
# macOS
brew install stow

# Debian/Ubuntu
sudo apt install stow
```

OS related setup scripts are in the `setup/` folder.

### Install

```shell
cd ~ && git clone --recursive git@github.com:theskumar/dotfiles.git
cd ~/dotfiles
./install.sh
```

`install.sh` stows all packages to `$HOME` and `$HOME/.config` based on your OS.

### Installing a single package

```shell
cd ~/dotfiles
stow shell                              # packages targeting $HOME (uses .stowrc default)
stow --target="$HOME/.config" ghostty  # packages targeting $HOME/.config
```

### Uninstalling a package

```shell
stow -D shell
```

## Packages

### Core (all machines)

| Package | Contents |
|---------|----------|
| `shell` | .aliases, .bashrc, .exports, .functions, .inputrc, .profile |
| `zsh` | .zshrc, .zshenv, .zsh/ (plugins, functions, lib) |
| `git` | .gitconfig, .gitmessage, .gitattributes, .config/git/ignore |
| `vim` | .vimrc, .vim/ |
| `tools` | .ackrc, .actrc, .carbon-now.json, .cookiecutterrc, .curlrc, .nuxtrc, .pythonrc.py, .wgetrc |
| `ssh` | .ssh/config.sample |
| `fonts` | .fonts/ (Hermit, Source Code Pro) |

### Editor and terminal (XDG, stowed to ~/.config)

| Package | Contents |
|---------|----------|
| `ghostty` | Terminal config with tmux keybind layer |
| `zed` | settings.json, keymap.json, tasks.json, snippets/ |
| `lazygit` | Zed as external editor |
| `starship` | Prompt config |
| `tmux` | tmux.conf, tmux.reset.conf |
| `sesh` | Tmux session definitions |
| `tmuxinator` | Project layouts |
| `mise` | Global tool versions config |

### Git and dev tools (XDG)

| Package | Contents |
|---------|----------|
| `gh` | GitHub CLI config (aliases) |
| `gh-dash` | GitHub dashboard layout |
| `worktrunk` | Git worktree path templates |

### macOS specific

| Package | Target | Contents |
|---------|--------|----------|
| `macos` | $HOME | .aerospace.toml, .finicky.js, .hyprspace.toml, .osx |
| `omniwm` | ~/.config | OmniWM tiling WM (niri/dwindle layouts), workspaces, hotkeys, app rules |
| `borders` | ~/.config | Window border config (borderrc) |
| `sketchybar` | ~/.config | Status bar config, plugins/, items/, themes/, colors.sh |
| `karabiner` | (not stowed) | Keyboard customization (build based, has its own workflow) |

### Linux specific

| Package | Contents |
|---------|----------|
| `linux` | .linux, .xmobarrc, .Xresources, .xsession, .xsessionrc |
| `xmonad` | .xmonad/xmonad.hs |

### Other

| Package | Contents |
|---------|----------|
| `freebsd` | .freebsd |

## Not stowed

| Directory | Why |
|-----------|-----|
| `bin/` | Scripts added to PATH via .exports, not symlinked |
| `setup/` | One-shot install scripts, run manually |
| `karabiner/` | Build based workflow, outputs to ~/.config/karabiner/ |
| `pi/` | AI coding agent settings (~/.pi/agent/settings.json), stow manually if needed |
| `.private/` | Gitignored secrets |

## Notes

`~/.gitignore` is copied (not symlinked) by `install.sh` because Stow skips `.gitignore` files by default.
