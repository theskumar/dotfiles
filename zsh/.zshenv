# .zshenv — sourced for ALL zsh invocations (interactive, non-interactive, scripts).
# Keep this minimal: env vars + PATH only. No interactive features.

export PNPM_HOME="$HOME/Library/pnpm"

# Dedupe PATH automatically (zsh ties `path` array to PATH scalar).
typeset -U path PATH
path=(
  "$HOME/.local/bin"
  "$PNPM_HOME"
  $path
)

# Rust/Cargo env (sets PATH for ~/.cargo/bin if installed)
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
