#!/bin/zsh
# Start pi-web for the com.theskumar.pi-web LaunchAgent (macos package).
# Listens on all interfaces so tailnet devices can reach it.
# Secrets live in ~/.config/pi-web/env (not committed). Copy env.example to start.
export PATH="$HOME/.local/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
# Add mise global tools (node, pi) without pinning a node version here.
eval "$(mise env -s zsh -C "$HOME" 2>/dev/null)"
export PATH="$HOME/.pi/agent/bin:$PATH"
set -a; source "$HOME/.config/pi-web/env"; set +a
cd "$HOME"
exec pi-web -H 0.0.0.0 -p "${PORT:-30141}" --no-open
