# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Show current directory in terminal window title
update_terminal_cwd() {
    case "$PWD" in
        $HOME) title=$USER ;;
        $HOME*) title="~${PWD#$HOME}" ;;
        *) title=$PWD ;;
    esac
    printf "\033]0;$title\007" > /dev/tty
}
update_terminal_cwd
autoload add-zsh-hook
add-zsh-hook chpwd update_terminal_cwd

# Set up the prompt
autoload -U colors && colors    # Load colors
PS1="%B%{$fg[green]%}%n%{$fg[green]%}@%{$fg[green]%}%M%{$fg[white]%}:%{$fg[blue]%}%~%{$reset_color%}%#%b "

# Use emacs keybindings even if our EDITOR is set to vi
bindkey -e
bindkey '^[[1;5C' emacs-forward-word    # Ctrl+Right
bindkey '^[[1;5D' emacs-backward-word   # Ctrl+Left
bindkey '^[[3;5~' kill-word             # Ctrl+Delete
bindkey '^U' backward-kill-line         # Ctrl+U
bindkey '^[W' kill-region               # Alt+W

backward-kill-word-ctrl-bs() {
  local WORDCHARS=${WORDCHARS/\/}
  zle backward-kill-word
}
zle -N backward-kill-word-ctrl-bs
bindkey '^H' backward-kill-word-ctrl-bs # Ctrl+Backspace

# Edit the current command line in $EDITOR
autoload -U edit-command-line
zle -N edit-command-line
bindkey '\C-x\C-e' edit-command-line

# Data dir
mkdir -p ${XDG_DATA_HOME:-$HOME/.local/share}/zsh

# History in cache directory 
HISTSIZE=2000
SAVEHIST=2000
HISTFILE=${XDG_DATA_HOME:-$HOME/.local/share}/zsh/zsh_history
setopt histignorealldups sharehistory histignorespace

# Directory history
DIRSTACKSIZE=10
setopt autopushd pushdsilent pushdignoredups pushdminus

# Use modern completion system
autoload -Uz compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zmodload zsh/complist
compinit -d ${XDG_DATA_HOME:-$HOME/.local/share}/zsh/zcompdump 
_comp_options+=(globdots)               # Include hidden files.

# Use vim keys in tab complete menu
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history

# Aliases, functions, fzf-keybindings
source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/aliases"
source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/functions"
source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/fzf-key-bindings.zsh"
command -v lfcd &> /dev/null && bindkey -s '^o' '^ulfcd\n'

# Plugins
typeset -gA ZSH_HIGHLIGHT_STYLES
source "${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
source "${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh"
#bindkey "$terminfo[kcuu1]" history-substring-search-up
#bindkey "$terminfo[kcud1]" history-substring-search-down
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down