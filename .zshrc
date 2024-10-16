# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Report the current working directory to terminal
update_terminal_cwd() {
    local title=$PWD
    case "$PWD" in
        $HOME) title=$USER ;;
        $HOME*) title="~${PWD#$HOME}" ;;
    esac
    local cwd=$(printf '%s' "$PWD" | perl -lpe 's/([^A-Za-z0-9-.\/:_!\(\)~'"\'"'])/sprintf("%%%02X", ord($1))/seg')
    printf "\033]0;%s\007" "$title"
    printf "\033]7;file://%s%s\007" "$HOST" "$cwd"
}
update_terminal_cwd
autoload add-zsh-hook
add-zsh-hook chpwd update_terminal_cwd

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

# Don't remove a space before the pipe symbol
ZLE_REMOVE_SUFFIX_CHARS=$' \t\n;&)'

# Set up the prompt
if [[ $(tty) =~ tty[0-9]$ ]]; then
    export PROMPT_SEPARATOR=''
    export PROMPT_ELLIPSIS='...'
    export PROMPT_BRANCH=''
    export PROMPT_CONTEXT_BG=white
fi
source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/theme.zsh"

# Use emacs keybindings even if our EDITOR is set to vi
bindkey -e
bindkey '^[[1;5C' emacs-forward-word    # Ctrl+Right
bindkey '^[[1;5D' emacs-backward-word   # Ctrl+Left
bindkey '^[[3;5~' kill-word             # Ctrl+Delete
bindkey '^U' backward-kill-line         # Ctrl+U
bindkey '^[W' kill-region               # Alt+W
bindkey '\C-]' vi-find-next-char        # Ctrl+]
bindkey '\e\C-]' vi-find-prev-char      # Alt+Ctrl+]
bindkey '\e[3~' delete-char             # Delete

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

# Make sure the following completion dirs are in fpath
fpath[(i)/usr/local/share/zsh/site-functions]=()
fpath[(i)/usr/share/zsh/site-functions]=()
fpath=("/usr/local/share/zsh/site-functions" "/usr/share/zsh/site-functions" $fpath)

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

# Aliases and functions
source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/aliases"
source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/functions"

# Set up lf key binding
command -v lf &> /dev/null && bindkey -s '^o' '^u^klf\n'

# Set up fzf key bindings and fuzzy completion
command -v fzf &> /dev/null && eval "$(fzf --zsh)"
command -v fzf-alt-c &> /dev/null && export FZF_ALT_C_COMMAND="fzf-alt-c"
command -v fzf-ctrl-t &> /dev/null && export FZF_CTRL_T_COMMAND="fzf-ctrl-t"

# Plugins
typeset -gA ZSH_HIGHLIGHT_STYLES
source "${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
source "${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh"
bindkey "$terminfo[kcuu1]" history-substring-search-up
bindkey "$terminfo[kcud1]" history-substring-search-down
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey -M emacs '^P' history-substring-search-up
bindkey -M emacs '^N' history-substring-search-down
