#!/bin/bash

if test ! $(which brew); then
  echo "  Installing Homebrew for you."
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

brew update
brew upgrade

# GNU replacements for outdated macOS built-ins
brew install coreutils             # GNU file, shell, text utilities
brew install findutils             # GNU find, xargs, locate
brew install gnu-sed               # GNU stream editor
brew install grep                  # GNU grep with PCRE support
brew install bash                  # modern Bash 5.x
brew install curl                  # URL transfer tool
brew install wget                  # file downloader
brew install watch                 # run command periodically
brew install wdiff                 # word-level diff

# Shell
brew install zsh                   # Z shell
brew install zplug                 # zsh plugin manager
brew install fzf                   # fuzzy finder
brew install zoxide                # smarter cd with frecency
brew install eza                   # modern ls replacement
brew install tree                  # directory tree listing
brew install bat                   # cat with syntax highlighting
brew install fd                    # fast find alternative
brew install ripgrep               # fast recursive grep
brew install starship              # cross-shell prompt
brew install zsh-history-substring-search  # history search as you type
brew install spacer                # visual separator in command output
brew install yazi                  # TUI file manager
brew install superfile             # TUI file manager

# Git
brew install git                   # version control
brew install git-extras            # extra git commands (info, effort, etc.)
brew install git-filter-repo       # rewrite git history
brew install git-town              # branch workflow automation
brew install git-delta             # better diff pager
brew install git-trim              # prune merged branches
brew install gitleaks              # secret scanner
brew install lazygit               # TUI git client
brew install jj                    # Jujutsu VCS — Git-compatible, change-first model
brew install jjui                  # TUI for jj (like lazygit but for jj)
brew install gh                    # GitHub CLI
gh extension install dlvhdr/gh-dash  # GitHub dashboard TUI

# Search and HTTP
brew install ack                   # grep for source code
brew install httpie                # human-friendly HTTP client
brew install jq                    # JSON processor
brew install xsv                   # CSV toolkit

# Network diagnostics
brew install mtr                   # traceroute + ping combined
brew install ngrep                 # network packet grep
brew install nmap                  # network scanner and auditor
brew install mosh                  # mobile shell, survives roaming

# Network/Cloud services
brew install caddy                 # web server with automatic HTTPS
brew install cloudflared           # Cloudflare tunnel
brew install flyctl                # Fly.io CLI
brew install heroku/brew/heroku    # Heroku CLI
brew install snowflake-cli         # Snowflake developer CLI
brew install mailpit               # local email testing
brew install mkcert                # local HTTPS certs
brew install ttyd                  # terminal over web

# Media
brew install ffmpeg                # video/audio converter
brew install webp                  # WebP image tools
brew install graphviz              # DOT graph rendering
brew install imagemagick           # image manipulation toolkit
brew install sox                   # audio processing
brew install tesseract             # OCR engine
brew install gdal                  # geospatial data toolkit

# Docs and writing
brew install pandoc                # universal document converter
brew install glow                  # markdown renderer in terminal
brew install hugo                  # static site generator
brew install typst                 # modern typesetting
brew install monolith              # save web pages as single HTML
brew install weasyprint            # HTML to PDF

# Dev tools
brew install redis                 # in-memory data store
brew install stow                  # symlink farm manager
brew install ossp-uuid             # UUID generation library
brew install moor                  # human-friendly terminal pager
brew install htop                  # interactive process viewer
brew install mactop                # macOS system monitor
brew install ncdu                  # disk usage analyzer
brew install television            # fuzzy file finder TUI
brew install phockup               # organizes photos by EXIF date
brew tap ivandokov/homebrew-contrib
brew install just                  # command runner (Makefile alternative)
brew install rust                  # Rust toolchain
brew install cmake                 # build system generator
brew install php                   # PHP interpreter
brew install virtualenv            # Python virtual environments
brew install typos-cli             # spell checker for source code
brew install fsouza/prettierd/prettierd  # Prettier as a daemon
brew install avencera/tap/rustywind  # Tailwind class sorter
brew install dotenvx/brew/dotenvx  # dotenv with encryption support
brew install difftastic            # structural diffs (AST-aware)
brew install diffr                 # LCS-based diff highlighting
brew install adr-tools             # architecture decision records
brew install hf                    # Hugging Face CLI
brew install hl                    # log viewer

# Dotfiles companions (have stow packages in this repo)
brew install joshmedeski/sesh/sesh           # smart tmux session manager
brew install felixkratz/formulae/borders     # macOS window border highlights
brew install felixkratz/formulae/sketchybar  # custom macOS status bar
brew install tmuxinator            # tmux session manager
brew install worktrunk             # git worktree CLI for parallel work

# JS/Node
brew install fnm                   # Node version manager
brew install pnpm                  # fast Node package manager
brew install yarn                  # Node package manager

# Databases
brew install postgresql@16         # PostgreSQL 16
brew install postgresql@14         # PostgreSQL 14
brew install duckdb                # embedded analytical database
brew install litecli               # SQLite client with autocomplete
brew install valkey                # Redis fork (open source)
brew install pgsync                # Postgres data sync

# Linters and security
brew install semgrep               # static analysis tool
brew install zizmor                # GitHub Actions linter

# Benchmarking
brew install siege                 # HTTP load testing
brew install sloccount             # source line counter
brew install multitail             # tail multiple files simultaneously
brew install bombardier            # HTTP benchmarking

# Fun
brew install fortune               # random quotes
brew install cowsay                # ASCII cow messages
brew install cmatrix               # Matrix rain animation

# Niche/Hobby
brew install scarvalhojr/tap/aoc-cli  # Advent of Code CLI
brew install tw93/tap/mole         # macOS app uninstaller
brew install iwe-org/iwe/iwe       # markdown knowledge management

# Fonts
brew install --cask font-fira-code-nerd-font     # Fira Code with Nerd Font icons
brew install --cask font-hack-nerd-font          # Hack with Nerd Font icons
brew install --cask font-source-code-pro         # Adobe Source Code Pro
brew install --cask font-symbols-only-nerd-font  # Nerd Font icons only
brew install --cask sf-symbols                   # Apple SF Symbols

# Apps
brew install --cask ghostty              # GPU-accelerated terminal
brew install --cask orbstack             # Docker and Linux on macOS
brew install --cask obsidian             # markdown knowledge base
brew install --cask bruno                # API client
brew install --cask 1password-cli        # 1Password CLI
brew install --cask stats                # menu bar system monitor
brew install --cask monitorcontrol       # external display brightness
brew install --cask finicky              # default browser router
brew install --cask omniwm              # tiling window manager
brew install --cask basictex            # minimal TeX distribution
brew install --cask iterm2              # terminal emulator
brew install --cask karabiner-elements  # keyboard customizer
brew install --cask cmux                # AI agent terminal (Ghostty-based)
brew install --cask hyprspace           # tiling WM (AeroSpace fork)
brew install --cask kitlangton-hex      # voice-to-text transcription
brew install --cask thaw                # macOS menu bar manager

# Quick Look plugins
brew install --cask qlcolorcode qlstephen qlmarkdown quicklook-json qlprettypatch quicklook-csv betterzipql webp-quicklook suspicious-package
qlmanage -r

brew cleanup

exit 0
