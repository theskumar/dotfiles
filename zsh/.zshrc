# zmodload zsh/zprof

# ─── 1. Options ──────────────────────────────────────────────────────────────
# History
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000
setopt EXTENDED_HISTORY        # timestamps
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE       # ignore commands starting with space
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_VERIFY             # don't auto-execute !! expansions
setopt SHARE_HISTORY           # share across sessions
setopt INC_APPEND_HISTORY      # write immediately

# Shell behavior
setopt AUTO_CD                 # `cd foo` → just type `foo`
setopt AUTO_PUSHD              # `cd` pushes to dir stack
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT
setopt EXTENDED_GLOB
setopt INTERACTIVE_COMMENTS    # allow `# comments` in interactive shell
setopt NO_BEEP
# setopt CORRECT               # offer typo correction (optional)

# ─── 2. PATH / env ───────────────────────────────────────────────────────────
# PATH and core env vars live in ~/.zshenv (sourced for all invocations).
# ~/.profile loads ~/.exports, ~/.aliases, ~/.functions, ~/.extra, and OS-specific files.
source ~/.profile

# ─── 3. fpath setup ──────────────────────────────────────────────────────────
# Add local completions to fpath (must precede compinit in turbo block).
fpath=(~/.zsh/completions $fpath)

# ─── 4. Plugin manager + plugins (turbo/wait) ────────────────────────────────
### Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"

autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Shim compdef until turbo compinit runs (zicdreplay will replay these).
# Needed because the eval-based tool initializations below call compdef
# synchronously at startup, before zicompinit has executed.
if ! (( ${+functions[compdef]} )); then
  typeset -ga __deferred_compdefs
  compdef() { __deferred_compdefs+=("${(j: :)@}") }
fi

# # nvm
# export NVM_DIR="$HOME/.nvm"
# export NVM_LAZY_LOAD=true
# zinit light lukechilds/zsh-nvm

# Turbo-loaded plugins (deferred until after first prompt).
# atinit on the first plugin runs compinit once, then replays cached completions.
zinit wait lucid light-mode for \
    atinit"ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay; (( \${#__deferred_compdefs} )) && for c in \"\${__deferred_compdefs[@]}\"; do eval \"compdef \$c\"; done; unset __deferred_compdefs" \
        zdharma-continuum/fast-syntax-highlighting \
    atload"_zsh_autosuggest_start" \
        zsh-users/zsh-autosuggestions \
    blockf atpull'zinit creinstall -q .' \
        zsh-users/zsh-completions \
    atload"bindkey '^[[A' history-substring-search-up; bindkey '^[[B' history-substring-search-down" \
        zsh-users/zsh-history-substring-search \
    wfxr/forgit

# ─── 5. compinit ─────────────────────────────────────────────────────────────
# Handled inside the turbo block above (zicompinit + zicdreplay) for speed.

# ─── 6. Keybindings ──────────────────────────────────────────────────────────
# history-substring-search bindings are wired via atload above.
# fzf key-bindings are sourced below alongside its completions.
[[ -f /opt/homebrew/opt/fzf/shell/key-bindings.zsh ]] && source /opt/homebrew/opt/fzf/shell/key-bindings.zsh

# ─── 7. Tool initializations (cached) ────────────────────────────────────────
# Local completion config + fzf completions
source ~/.zsh/lib/completions.zsh
[[ -f /opt/homebrew/opt/fzf/shell/completion.zsh ]] && source /opt/homebrew/opt/fzf/shell/completion.zsh

eval "$(uv generate-shell-completion zsh)"
eval "$(zoxide init zsh --cmd j)"

# Node/Python/Go/etc. version management (replaces fnm, pyenv, etc.)
eval "$(~/.local/bin/mise activate zsh)"

if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init zsh)"; fi

# ─── 8. Prompt ───────────────────────────────────────────────────────────────
eval "$(starship init zsh)"
