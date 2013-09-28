ZSH=~/.zsh

source ~/.profile

fpath=(~/.zsh/functions $fpath)
fpath=(~/.zsh/zsh-completions/src $fpath)
autoload -U ~/.zsh/functions/*(:t)

# predictive typing (`man zshcontrib`)
#autoload -U predict-on
#zle-line-init(){ predict-on }
#zle -N zle-line-init
#zstyle ':predict' toggle true
##zstyle ':predict' verbose true

# for config_file ($ZSH/lib/*.zsh) source $config_file

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

unsetopt flowcontrol
unsetopt beep


### Key bindings ###
bindkey -e
bindkey '^P' history-beginning-search-backward
bindkey '^N' history-beginning-search-forward
bindkey '^[[Z' reverse-menu-complete
bindkey '^[/' undo

zle -N rationalize-dot
bindkey . rationalize-dot


# configure zsh's autocompletion system; man zshcompsys
zstyle ':completion:*' use-cache on

zstyle ':completion:*' completer _expand _complete _match _approximate
zstyle ':completion:*' matcher-list '+' '+m:{[:lower:]}={[:upper:]}' '+r:|[._-]=** r:|=**' '+l:|=* r:|=*'
zstyle ':completion:*:match:*' original only
zstyle -e ':completion:*' max-errors 'reply=( $(( ($#PREFIX+$#SUFFIX)/3 )) numeric )'
zstyle ':completion:*:functions' ignored-patterns '_*'
zstyle ':completion:*' ignore-parents parent pwd
zstyle ':completion:*' list-suffixes true
zstyle ':completion:*' expand suffix
zstyle ':completion:*:kill:*' command 'ps -u$USER'

zstyle ':completion::expand:*' tag-order 'expansions all-expansions'
zstyle ':completion:*' remove-all-dups true
zstyle ':completion:*' group-name ''
zstyle ':completion:*' format '%B%d:%b'
zstyle ':completion:*' verbose true
zstyle ':completion:*' list-colors no=00 fi=00 di=01\;34 pi=33 so=01\;35 bd=00\;35 cd=00\;34 or=00\;41 mi=00\;45 ex=01\;32
zstyle ':completion:*' menu 'select=0'
zstyle ':completion:*' list-prompt ''
zstyle ':completion:*' select-prompt ''

zstyle ':completion:*' insert-tab false
zstyle ':completion:*' prompt ''\''%e'\'''
zstyle ':completion:*:manuals' separate-sections true

# Load plugins
plugins=(git greetings git-flow gibo)
#plugins=(git)

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


# Initialize prompt

#PROMPT=$'%{$fg_bold[green]%}%n@%m %{$fg[blue]%}%D{[%I:%M:%S]} %{$reset_color%}%{$fg[green]%}[%~]%{$reset_color%} $(git_prompt_info)\
#    %{$fg[blue]%}->%{$fg_bold[blue]%} %#%{$reset_color%} '
PROMPT=$'%{$fg_bold[blue]%}%n@%m %{$reset_color%}%{$fg[green]%}[%~]%{$reset_color%} $(git_prompt_info)\
    %{$fg[blue]%}->%{$fg_bold[blue]%} %#%{$reset_color%} '

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[green]%}["
ZSH_THEME_GIT_PROMPT_SUFFIX="]%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY=" %{$fg[red]%}*%{$fg[green]%}"
ZSH_THEME_GIT_PROMPT_CLEAN=""
ZSH_THEME_GIT_PROMPT_AHEAD="^"
ZSH_THEME_GIT_PROMPT_ADDED="+"
ZSH_THEME_GIT_PROMPT_UNTRACKED="?"
ZSH_THEME_GIT_PROMPT_MODIFIED="*"
ZSH_THEME_GIT_PROMPT_DELETED="%{$fg[red]%}-%{$fg[green]%}"


### Exports
export _JAVA_AWT_WM_NONREPARENTING=1

precmd() {
    # send a visual bell to awesome
    echo -ne '\a'
}

# Title
precmd_functions=( "${precmd_functions[@]:#_title_precmd}" _title_precmd )
preexec_functions=( "${preexec_functions[@]:#_title_preexec}" _title_preexec )

# Auto jump; https://github.com/sjl/z-zsh
. $HOME/.zsh/z/z.sh

autoload -U colors
colors
setopt prompt_subst

precmd_functions=( "${precmd_functions[@]:#_z_precmd}" _z_precmd )

source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/.zsh/zsh-history-substring-search/zsh-history-substring-search.zsh

# Detect and load OS specific settigs
platform='unknown'
unamestr=`uname`
if [[ "$unamestr" == 'Linux' ]]; then
   source ~/.zsh/.linux
elif [[ "$unamestr" == 'FreeBSD' ]]; then
   source ~/.zsh/.freebsd
elif [[ "$unamestr" == 'Darwin' ]]; then
   source ~/.zsh/.osx
fi


# PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting
PATH=$PATH:$HOME/bin/ec2/bin # Add PATH to ec2 commandline tools.


# added by travis gem
source /Users/Web3/.travis/travis.sh
