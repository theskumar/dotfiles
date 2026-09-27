[ -n "$PS1" ] && source ~/.profile
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
[ -f "$HOME/.deno/env" ] && . "$HOME/.deno/env"
if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init bash)"; fi
