#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES"

OS="$(uname -s)"

COMMON=(shell zsh git vim tools ssh fonts)

XDG=(starship tmux)

case "$OS" in
    Darwin)
        OS_PKGS=(macos)
        XDG+=(borders sketchybar)
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

echo "==> Done. Run 'source ~/.zshrc' to reload shell."
