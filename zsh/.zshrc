# zmodload zsh/zprof

autoload -Uz compinit
compinit -i

HISTSIZE=100000
SAVEHIST=100000
setopt HIST_IGNORE_DUPS
setopt HIST_FIND_NO_DUPS

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

# # nvm
# export NVM_DIR="$HOME/.nvm"
# export NVM_LAZY_LOAD=true
# zinit light lukechilds/zsh-nvm

# Load completions
zinit ice blockf
zinit light zsh-users/zsh-completions

zinit snippet 'https://github.com/robbyrussell/oh-my-zsh/raw/master/plugins/git/git.plugin.zsh'

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

eval "$(uv generate-shell-completion zsh)"
eval "$(zoxide init zsh --cmd j)"

source ~/.profile
# zprof

# fnm
FNM_PATH="/opt/homebrew/opt/fnm/bin"
if [ -d "$FNM_PATH" ]; then
  eval "`fnm env`"
fi
