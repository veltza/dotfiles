# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# Set the terminal title to reflect the current working directory
update_terminal_title() {
    local title=$PWD
    case "$PWD" in
        $HOME) title=$USER ;;
        $HOME*) title="~${PWD#$HOME}" ;;
    esac
    printf "\033]0;$title\007" > /dev/tty
}
update_terminal_title
export PROMPT_COMMAND="${PROMPT_COMMAND:-}${PROMPT_COMMAND:+";"}update_terminal_title"

# Data dir
mkdir -p "${XDG_DATA_HOME:-$HOME/.local/share}/bash"

# History size and location
HISTSIZE=10000
HISTFILESIZE=10000
HISTFILE=${XDG_DATA_HOME:-$HOME/.local/share}/bash/bash_history

# Don't put duplicate lines or lines starting with space in the history
HISTCONTROL=ignoreboth

# Append to the history file, don't overwrite it
shopt -s histappend

# Check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# Set up the prompt
if [[ $(tty) =~ tty[0-9]$ ]]; then
    export PROMPT_SEPARATOR=''
    export PROMPT_BRANCH=''
    export PROMPT_CONTEXT_BG=255
fi
source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/theme.bash"

# Enable bash completion, if it's not already enabled in /etc/bash.bashrc
if ! shopt -oq posix && [ -z "${BASH_COMPLETION_VERSINFO:-}" ]; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

# Aliases, functions and zoxide
source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/aliases"
source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/functions"
source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/bash-dirhistory"
command -v zoxide &> /dev/null && eval "$(zoxide init bash)"

# Set up lf key binding
command -v lf &> /dev/null && bind '"\C-o":"\C-u\C-klf\C-m"'

# Set up fzf key bindings and fuzzy completion
if command -v fzf &> /dev/null; then
    eval "$(fzf --bash)"
    __fzf_cd__() {
        local opts dir
        opts="--height ${FZF_TMUX_HEIGHT:-40%} --bind=ctrl-z:ignore --reverse --walker=dir,follow,hidden --scheme=path ${FZF_DEFAULT_OPTS-} ${FZF_ALT_C_OPTS-} +m"
        dir=$(
          FZF_DEFAULT_COMMAND=${FZF_ALT_C_COMMAND:-} FZF_DEFAULT_OPTS="$opts" $(__fzfcmd)
        ) && printf 'cd -- %q' "$dir"
    }
    _fzf_setup_completion path lvim v
    _fzf_setup_completion dir tree
    command -v fzf-alt-c &> /dev/null && export FZF_ALT_C_COMMAND="fzf-alt-c"
    command -v fzf-ctrl-t &> /dev/null && export FZF_CTRL_T_COMMAND="fzf-ctrl-t"
fi

# Colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'
