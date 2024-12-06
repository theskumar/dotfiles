# Fig pre block. Keep at the top of this file.
. "$HOME/.fig/shell/zshrc.pre.zsh"

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

source ~/.profile
export ZPLUG_HOME=/opt/homebrew/opt/zplug
source $ZPLUG_HOME/init.zsh

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

fpath=($ZSH/functions $fpath)
autoload -U $ZSH/functions/*(:t)

# predictive typing (`man zshcontrib`)
#autoload -U predict-on
#zle-line-init(){ predict-on }
#zle -N zle-line-init
#zstyle ':predict' toggle true
##zstyle ':predict' verbose true
# zstyle ':completion:*:*:git:*' script $ZSH/.git-completion.sh

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

plugins=(git gibo django pure web_search gpg-crypt)

is_plugin() {
  local base_dir=$1
  local name=$2
  test -f $base_dir/plugins/$name/$name.plugin.zsh \
    || test -f $base_dir/plugins/$name/_$name
}
# Add all defined plugins to fpath. This must be done
# before running compinit.
for plugin ($plugins); do
    if is_plugin $ZSH $plugin; then
      fpath=($ZSH/plugins/$plugin $fpath)
    fi
done

# Figure out the SHORT hostname
if [ -n "$commands[scutil]" ]; then
  # OS X
  SHORT_HOST=$(scutil --get ComputerName)
else
  SHORT_HOST=${HOST/.*/}
fi

# Save the location of the current completion dump file.
ZSH_COMPDUMP="${ZDOTDIR:-${HOME}}/.zcompdump-${SHORT_HOST}-${ZSH_VERSION}"

# Load and run compinit
autoload -U compinit
compinit -i -d "${ZSH_COMPDUMP}"

# Load all of the plugins that were defined in ~/.zshrc
for plugin ($plugins); do
    source $ZSH/plugins/$plugin/$plugin.plugin.zsh
done

# Section: zplug
zplug "supercrabtree/k", as:command

# https://github.com/sindresorhus/pure
zplug "mafredri/zsh-async", from:github
zplug "sindresorhus/pure", use:pure.zsh, from:github, as:theme

zplug "zsh-users/zsh-history-substring-search", from:github
zplug "zsh-users/zsh-syntax-highlighting", defer:2
zplug "zsh-users/zsh-completions"
zplug "plugins/git",    from:oh-my-zsh
zplug "plugins/gh",     from:oh-my-zsh
zplug "plugins/fig",     from:oh-my-zsh

zplug load

precmd() {
    # send a visual bell to awesome
    echo -ne '\a'
}

# Title
precmd_functions=( "${precmd_functions[@]:#_title_precmd}" _title_precmd )
preexec_functions=( "${preexec_functions[@]:#_title_preexec}" _title_preexec )


# ---[ Modules ]--------------------------------------------------------

zmodload zsh/terminfo

# Use Alt-Arrows to skip words
bindkey -e
bindkey '^[^[[C' forward-word
bindkey '^[^[[D' backward-word

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

precmd_functions=( "${precmd_functions[@]:#_z_precmd}" _z_precmd )

## smart urls
autoload -U url-quote-magic
zle -N self-insert url-quote-magic

eval "$(zoxide init zsh --cmd j)"
