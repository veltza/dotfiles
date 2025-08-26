# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# Include shell functions
source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/functions.sh"

# Report the current working directory to the terminal when the directory is changed
export PROMPT_COMMAND="${PROMPT_COMMAND:-}${PROMPT_COMMAND:+";"}update_terminal_cwd"

# Data dir
mkdir -p "${XDG_STATE_HOME:-$HOME/.local/state}/bash"

# History size and location
HISTSIZE=10000
HISTFILESIZE=10000
HISTFILE=${XDG_STATE_HOME:-$HOME/.local/state}/bash/bash_history

# Don't put duplicate lines or lines starting with space in the history
HISTCONTROL=ignoreboth

# Append to the history file, don't overwrite it
shopt -s histappend

# Check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# The pattern ‘**’ matches all files and zero or more dirs and subdirs.
shopt -s globstar

# Set up the prompt
if [[ $(tty) =~ tty[0-9]$ ]]; then
    export PROMPT_SEPARATOR=''
    export PROMPT_PLUSMINUS='+'
    export PROMPT_BRANCH=''
    export PROMPT_CONTEXT_BG=255
else
    export PROMPT_SEPARATOR=$'\ue0b0'
    export PROMPT_PLUSMINUS=$'\u00b1'
    export PROMPT_BRANCH=$'\ue0a0'
    export PROMPT_CONTEXT_BG=253
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

# Aliases, dirhistory and zoxide
source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/aliases.sh"
source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/dirhistory.bash"
command -v zoxide &> /dev/null && eval "$(zoxide init bash)"

# Set up lf key binding
command -v lf &> /dev/null && bind '"\C-o":"\C-u\C-klf\C-m"'

# Set up fzf key bindings and fuzzy completion
if command -v fzf &> /dev/null; then
    eval "$(fzf --bash)"
    __fzf_cd__() {
        local dir
        dir=$(
            FZF_DEFAULT_COMMAND=${FZF_ALT_C_COMMAND:-} \
            FZF_DEFAULT_OPTS=$(__fzf_defaults "--reverse --walker=dir,follow,hidden --scheme=path" "${FZF_ALT_C_OPTS-} +m") \
            FZF_DEFAULT_OPTS_FILE='' $(__fzfcmd)
        ) && printf 'cd -- %q' "$(builtin unset CDPATH && builtin cd -- "$dir" && builtin pwd)"
    }
    _fzf_setup_completion path lvim v
    _fzf_setup_completion dir tree
    command -v fzf-alt-c &> /dev/null && export FZF_ALT_C_COMMAND="fzf-alt-c"
    command -v fzf-ctrl-t &> /dev/null && export FZF_CTRL_T_COMMAND="fzf-ctrl-t"
fi

# Colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'
