[ -n "$PS1" ] && source ~/.profile
. "$HOME/.cargo/env"
. "/Users/theskumar/.deno/env"
if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init bash)"; fi
