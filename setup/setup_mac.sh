#!/bin/bash
#
# macOS bootstrap. Homebrew packages are declared in a Brewfile owned by the
# brew-manage submodule (../brew-manage/Brewfile). This script installs
# Homebrew, runs `brew bundle`, then handles the non-brew installs that a
# Brewfile cannot express (gh extensions, bun, npm globals).
#
# Manage the package list:  edit brew-manage/Brewfile
#   brew bundle   --file=brew-manage/Brewfile   # install/update
#   brew bundle check   --file=brew-manage/Brewfile --verbose
#   brew bundle cleanup --file=brew-manage/Brewfile   # remove strays (review!)

set -uo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BREWFILE="$DOTFILES/brew-manage/Brewfile"

# Install Homebrew if missing
if ! command -v brew >/dev/null 2>&1; then
  echo "==> Installing Homebrew"
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

brew update
brew upgrade

# Ensure the brew-manage submodule (and its Brewfile) is present
if [ ! -f "$BREWFILE" ]; then
  echo "==> brew-manage submodule missing; fetching"
  git -C "$DOTFILES" submodule update --init --recursive brew-manage
fi

# Install everything declared in the Brewfile (taps, formulae, casks)
echo "==> brew bundle ($BREWFILE)"
brew bundle --file="$BREWFILE"

# --- Non-brew installs (cannot live in a Brewfile) -------------------------

# GitHub CLI dashboard extension
gh extension install dlvhdr/gh-dash 2>/dev/null || true

# Bun — fast JS runtime, bundler, test runner, package manager
if ! command -v bun >/dev/null 2>&1; then
  curl -fsSL https://bun.sh/install | bash
fi

# Node global packages
npm install -g readability-cli   # Mozilla Readability CLI (newsboat ,r macro)

# Moshi (iPhone integration) — pair once, interactively:
#   moshi-hook host setup          → shows QR code, scan in Moshi iOS app
#   brew services start rjyo/moshi/moshi-hook

# Refresh Quick Look after installing the QL plugin casks
qlmanage -r

brew cleanup

exit 0
