# zmodload zsh/zprof

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

source ~/.profile

eval "$(starship init zsh)"

# Created by `pipx` on 2022-07-05 05:47:49
export PATH="$PATH:/Users/theskumar/.local/bin"

# pnpm
export PNPM_HOME="/Users/theskumar/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end


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

# # nvm
# export NVM_DIR="$HOME/.nvm"
# export NVM_LAZY_LOAD=true
# zinit light lukechilds/zsh-nvm

# Add local completions + cache to fpath (must be set before compinit runs in turbo block)
fpath=(~/.zsh/completions $fpath)

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

zinit wait lucid for \
    OMZP::git

# Shim compdef until turbo compinit runs (zicdreplay will replay these).
# Needed because the eval-based completions below (uv/zoxide/mise/wt) call
# compdef synchronously at startup, before zicompinit has executed.
if ! (( ${+functions[compdef]} )); then
  typeset -ga __deferred_compdefs
  compdef() { __deferred_compdefs+=("${(j: :)@}") }
fi

# Load local completion config and fzf integration
source ~/.zsh/lib/completions.zsh
[[ -f /opt/homebrew/opt/fzf/shell/completion.zsh ]] && source /opt/homebrew/opt/fzf/shell/completion.zsh
[[ -f /opt/homebrew/opt/fzf/shell/key-bindings.zsh ]] && source /opt/homebrew/opt/fzf/shell/key-bindings.zsh

eval "$(uv generate-shell-completion zsh)"
eval "$(zoxide init zsh --cmd j)"

# fnm
FNM_PATH="/opt/homebrew/opt/fnm/bin"
if [ -d "$FNM_PATH" ]; then
  eval "`fnm env`"
fi
eval "$(~/.local/bin/mise activate zsh)"

if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init zsh)"; fi
