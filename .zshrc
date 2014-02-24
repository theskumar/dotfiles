ZSH=~/.zsh

source ~/.profile

# Uncomment following line if you want to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable command autocorrection
# DISABLE_CORRECTION="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
# COMPLETION_WAITING_DOTS="true"


# Load all of the config files in ~/.zsh/lib that end in .zsh
# TIP: Add files you don't want in git to .gitignore
for config_file ($ZSH/lib/*.zsh); do
  source $config_file
done

fpath=(~/.zsh/functions $fpath)
fpath=(~/.zsh/modules/zsh-completions/src $fpath)
autoload -U ~/.zsh/functions/*(:t)

# predictive typing (`man zshcontrib`)
#autoload -U predict-on
#zle-line-init(){ predict-on }
#zle -N zle-line-init
#zstyle ':predict' toggle true
##zstyle ':predict' verbose true


# Hooks
typeset -ga precmd_functions
typeset -ga preexec_functions

HISTFILE=~/.histfile
HISTSIZE=5000
SAVEHIST=5000

# zsh options; man zshoptions
setopt sharehistory
setopt histignoredups
setopt histignorealldups
setopt histfindnodups
setopt histignorespace

setopt extendedglob
setopt notify
# setopt correct
setopt interactivecomments
setopt multios

setopt autocd
setopt autopushd
setopt pushdignoredups
setopt pushdsilent

setopt autolist
unsetopt listambiguous

setopt listpacked
setopt listtypes

unsetopt beep


# ---[ Plugins ]---------------------------------------------------------

plugins=(git gibo autojump)

is_plugin() {
  local base_dir=$1
  local name=$2
  test -f $base_dir/plugins/$name/$name.plugin.zsh \
    || test -f $base_dir/plugins/$name/_$name
}
# Add all defined plugins to fpath. This must be done
# before running compinit.
for plugin ($plugins); do
    fpath=($ZSH/plugins/$plugin $fpath)
done

autoload -Uz compinit
compinit

# Load all of the plugins that were defined in ~/.zshrc
for plugin ($plugins); do
    source $ZSH/plugins/$plugin/$plugin.plugin.zsh
done


precmd() {
    # send a visual bell to awesome
    echo -ne '\a'
}

# Title
precmd_functions=( "${precmd_functions[@]:#_title_precmd}" _title_precmd )
preexec_functions=( "${preexec_functions[@]:#_title_preexec}" _title_preexec )


# ---[ Modules ]--------------------------------------------------------

. $HOME/.zsh/modules/z/z.sh
source ~/.zsh/modules/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/.zsh/modules/zsh-history-substring-search/zsh-history-substring-search.zsh

zmodload zsh/terminfo
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

precmd_functions=( "${precmd_functions[@]:#_z_precmd}" _z_precmd )
