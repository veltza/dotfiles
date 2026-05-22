# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Include shell functions
source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/functions.sh"

# Report the current working directory to the terminal when the directory is changed
autoload add-zsh-hook
add-zsh-hook chpwd update_terminal_cwd
update_terminal_cwd

# Data dir
mkdir -p "${XDG_STATE_HOME:-$HOME/.local/state}/zsh"

# History size, location and settings
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=${XDG_STATE_HOME:-$HOME/.local/state}/zsh/zsh_history
setopt histignorealldups sharehistory histignorespace

# Directory history
DIRSTACKSIZE=10
setopt autopushd pushdsilent pushdignoredups pushdminus

# Allow comments in interactive shells (like Bash does)
setopt interactive_comments

# Don't remove a space before the pipe and the ampersand symbols
ZLE_REMOVE_SUFFIX_CHARS=$' \t\n;)'

# Set up the prompt
if [[ $(tty) =~ tty[0-9]$ || $XDG_SESSION_TYPE == tty ]]; then
    export PROMPT_SEPARATOR=''
    export PROMPT_PLUSMINUS='+'
    export PROMPT_ELLIPSIS='...'
    export PROMPT_BRANCH=''
    export PROMPT_CONTEXT_BG=white
else
    export PROMPT_SEPARATOR=$'\ue0b0'
    export PROMPT_PLUSMINUS=$'\u00b1'
    export PROMPT_ELLIPSIS='…'
    export PROMPT_BRANCH=$'\ue0a0'
    export PROMPT_CONTEXT_BG=253
fi
source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/theme.zsh"

# Use emacs keybindings even if our EDITOR is set to vi
bindkey -e
bindkey '^[[1;5C' vi-forward-word  # Ctrl+Right
bindkey '^[[1;5D' vi-backward-word # Ctrl+Left
bindkey '\e[M' kill-subword        # Ctrl+Delete
bindkey '^[[3;5~' kill-subword     # Ctrl+Delete
bindkey '^H' backward-kill-subword # Ctrl+Backspace
bindkey '^U' backward-kill-line    # Ctrl+U
bindkey '^[f' forward-word         # Alt+f
bindkey '^[b' backward-word        # Alt+b
bindkey '^[F' vi-forward-word      # Alt+F
bindkey '^[B' vi-backward-word     # Alt+B
bindkey '^[d' kill-word            # Alt+d
bindkey '^[D' kill-subword         # Alt+D
bindkey '^[e' expand-word          # Alt+e
bindkey '^[s' vi-find-next-char    # Alt+s
bindkey '^[S' vi-find-prev-char    # Alt+S
bindkey '^[t' transpose-words      # Alt+t
bindkey '^[T' transpose-subwords   # Alt+T
bindkey '^[w' copy-region-as-kill  # Alt+w
bindkey '^[W' kill-region          # Alt+W
bindkey '\e[3~' delete-char        # Delete
bindkey -r "^['"                   # Remove Alt+'

kill-subword() {
    local WORDCHARS=''
    zle kill-word
}
zle -N kill-subword

backward-kill-subword() {
    local WORDCHARS=''
    zle backward-kill-word
}
zle -N backward-kill-subword

transpose-subwords() {
    local WORDCHARS=''
    zle transpose-words
}
zle -N transpose-subwords

# Edit the current command line in $EDITOR
autoload -U edit-command-line
zle -N edit-command-line
bindkey '\C-x\C-e' edit-command-line

# Copy the earlier word from the previous line. (Should be used with Alt+.)
autoload -Uz copy-earlier-word
zle -N copy-earlier-word
bindkey "^[m" copy-earlier-word  # Alt+m

# Make sure the following completion dirs are in fpath
fpath[(i)/usr/local/share/zsh/site-functions]=()
fpath[(i)/usr/share/zsh/site-functions]=()
fpath=("${XDG_DATA_HOME:-$HOME/.local/share}/zsh/completions" "/usr/local/share/zsh/site-functions" "/usr/share/zsh/site-functions" $fpath)

# Use modern completion system
autoload -Uz compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' matcher-list '' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zmodload zsh/complist
compinit -d "${XDG_STATE_HOME:-$HOME/.local/state}/zsh/zcompdump"
_comp_options+=(globdots) # Include hidden files

# Initialize zoxide
command -v zoxide &> /dev/null && source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/zoxide-init-cd.zsh"

# Use vim keys in tab complete menu
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect '^[[Z' reverse-menu-complete # Shift+Tab

# Aliases
source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/aliases.sh"

# Set up lf key binding
command -v lf &> /dev/null && bindkey -s '^o' '^u^klf\n'

# Set up fzf key bindings and fuzzy completion
command -v fzf &> /dev/null && eval "$(fzf --zsh)"
command -v fzf-alt-c &> /dev/null && export FZF_ALT_C_COMMAND="fzf-alt-c"
command -v fzf-ctrl-t &> /dev/null && export FZF_CTRL_T_COMMAND="fzf-ctrl-t"

# Plugins
typeset -gA ZSH_HIGHLIGHT_STYLES=(comment 'fg=none')
source "${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
source "${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh"
bindkey "$terminfo[kcuu1]" history-substring-search-up
bindkey "$terminfo[kcud1]" history-substring-search-down
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey -M emacs '^P' history-substring-search-up
bindkey -M emacs '^N' history-substring-search-down
