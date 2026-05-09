bindkey -e

# Edit the current command line in $EDITOR
autoload -U edit-command-line
zle -N edit-command-line
bindkey '\C-x\C-e' edit-command-line

bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

bindkey '^[[Z' reverse-menu-complete
bindkey '^[/' undo

# auto expand dot to path
zle -N rationalize-dot
bindkey . rationalize-dot
