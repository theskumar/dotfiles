# .zshenv — sourced for ALL zsh invocations (interactive, non-interactive, scripts).
# Keep this minimal: env vars + PATH only. No interactive features.

export PNPM_HOME="$HOME/Library/pnpm"

# Dedupe PATH automatically (zsh ties `path` array to PATH scalar).
typeset -U path PATH
path=(
  "$HOME/bin"
  "$HOME/dotfiles/bin"
  "$HOME/.local/bin"
  "$PNPM_HOME"
  $path
)

# Rust/Cargo env (sets PATH for ~/.cargo/bin if installed)
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# pi inline images: herdr advertises TERM=screen, which disables image output.
# Force kitty protocol (Ghostty outer terminal + herdr [experimental].kitty_graphics).
export PI_IMAGE_PROTOCOL=kitty
