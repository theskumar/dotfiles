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

zinit ice depth=1; zinit load zdharma-continuum/fast-syntax-highlighting
zinit ice depth=1; zinit load zsh-users/zsh-history-substring-search
zinit ice depth=1; zinit load zsh-users/zsh-autosuggestions
zinit load wfxr/forgit

# # nvm
# export NVM_DIR="$HOME/.nvm"
# export NVM_LAZY_LOAD=true
# zinit light lukechilds/zsh-nvm

# Load completions
zinit ice blockf
zinit light zsh-users/zsh-completions

# Add local completions to fpath
fpath=(~/.zsh/completions $fpath)

# Run compinit after all completion plugins are loaded
autoload -Uz compinit
zcompdump="${ZDOTDIR:-$HOME}/.zcompdump"
if [[ -n "$zcompdump"(#qN.mh+24) ]]; then
  compinit -d "$zcompdump"
else
  compinit -C -d "$zcompdump"
fi
# Compile the dump for faster loads on subsequent shells
if [[ -s "$zcompdump" && (! -s "${zcompdump}.zwc" || "$zcompdump" -nt "${zcompdump}.zwc") ]]; then
  zcompile "$zcompdump"
fi

# Load local completion config and fzf integration
source ~/.zsh/lib/completions.zsh
[[ -f /opt/homebrew/opt/fzf/shell/completion.zsh ]] && source /opt/homebrew/opt/fzf/shell/completion.zsh
[[ -f /opt/homebrew/opt/fzf/shell/key-bindings.zsh ]] && source /opt/homebrew/opt/fzf/shell/key-bindings.zsh

# kubectl completions (cached)
if command -v kubectl &>/dev/null; then
  if [[ ! -f ~/.zsh/cache/_kubectl ]] || [[ $(date +%s) -gt $(( $(date -r ~/.zsh/cache/_kubectl +%s 2>/dev/null || echo 0) + 86400 )) ]]; then
    mkdir -p ~/.zsh/cache && kubectl completion zsh > ~/.zsh/cache/_kubectl
  fi
  source ~/.zsh/cache/_kubectl
fi

zinit snippet 'https://github.com/robbyrussell/oh-my-zsh/raw/master/plugins/git/git.plugin.zsh'

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

eval "$(uv generate-shell-completion zsh)"
eval "$(zoxide init zsh --cmd j)"

# fnm
FNM_PATH="/opt/homebrew/opt/fnm/bin"
if [ -d "$FNM_PATH" ]; then
  eval "`fnm env`"
fi
eval "$(~/.local/bin/mise activate zsh)"

if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init zsh)"; fi
