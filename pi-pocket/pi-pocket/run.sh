#!/bin/zsh
# Start pi-pocket for the com.theskumar.pi-pocket LaunchAgent (macos package).
# Listens on all interfaces (lan access) so tailnet devices can reach it.
# The source checkout lives in ~/code/pi-pocket (git clone, then npm install).
# Optional overrides live in ~/.config/pi-pocket/env (not committed).
export PATH="$HOME/.local/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
# Add mise global tools (node, pi) without pinning a node version here.
eval "$(mise env -s zsh -C "$HOME" 2>/dev/null)"
export PATH="$HOME/.pi/agent/bin:$PATH"
if [[ -f "$HOME/.config/pi-pocket/env" ]]; then
    set -a; source "$HOME/.config/pi-pocket/env"; set +a
fi

# pi-claude-bridge preload registers the Claude provider in the Pocket server.
# The launcher passes NODE_OPTIONS to the server child it spawns.
preload="${PI_POCKET_PRELOAD:-$HOME/code/pi-claude-bridge/src/pocket-preload.ts}"
if [[ -f "$preload" ]]; then
    export NODE_OPTIONS="--import $preload${NODE_OPTIONS:+ $NODE_OPTIONS}"
else
    print -u2 "pi-pocket: preload not found, starting without it: $preload"
fi

src="${PI_POCKET_SRC:-$HOME/code/pi-pocket}"
cd "$src"
exec npm start -- \
    --access "${PI_POCKET_ACCESS:-lan}" \
    --port "${PI_POCKET_PORT:-30142}" \
    --cwd "$HOME"
