#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES"

OS="$(uname -s)"

COMMON=(shell zsh git vim tools ssh fonts)

XDG=(starship tmux ghostty gh gh-dash lazygit jj mise sesh zed tmuxinator worktrunk helix karabiner)

case "$OS" in
    Darwin)
        OS_PKGS=(macos)
        XDG+=(borders sketchybar omniwm)
        ;;
    Linux)
        OS_PKGS=(linux xmonad)
        ;;
    FreeBSD)
        OS_PKGS=(freebsd)
        ;;
    *)
        OS_PKGS=()
        ;;
esac

mkdir -p "$HOME/.config"

echo "==> Stowing common packages to \$HOME"
stow --target="$HOME" --restow "${COMMON[@]}"

echo "==> Stowing XDG packages to \$HOME/.config"
stow --target="$HOME/.config" --restow "${XDG[@]}"

if [ ${#OS_PKGS[@]} -gt 0 ]; then
    echo "==> Stowing OS-specific packages ($OS)"
    stow --target="$HOME" --restow "${OS_PKGS[@]}"
fi

if [ ! -f "$HOME/.gitignore" ]; then
    echo "==> Copying global .gitignore (stow skips .gitignore files)"
    cp "$DOTFILES/.gitignore" "$HOME/.gitignore"
fi

echo "==> Done. Run 'source ~/.zshrc' to reload shell."
