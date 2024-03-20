# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# Set the terminal title to reflect the current working directory.
update_terminal_title() {
    case "$PWD" in
        $HOME) title=$USER ;;
        $HOME*) title="~${PWD#$HOME}" ;;
        *) title=$PWD ;;
    esac
    printf "\033]0;$title\007" > /dev/tty
}
update_terminal_title
export PROMPT_COMMAND="${PROMPT_COMMAND:-}${PROMPT_COMMAND:+";"}update_terminal_title"

# Data dir
mkdir -p "${XDG_DATA_HOME:-$HOME/.local/share}/bash"

# Don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# Append to the history file, don't overwrite it
shopt -s histappend

# For setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=10000
HISTFILESIZE=10000
HISTFILE=${XDG_DATA_HOME:-$HOME/.local/share}/bash/bash_history

# Check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# Make less more friendly for non-text input files, see lesspipe(1)
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# Uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

parse_git_branch() {
    branch="$(git symbolic-ref --short HEAD 2>/dev/null)" || \
    branch="tags/$(git describe --tags --exact-match HEAD 2>/dev/null)" || \
    branch="$(git describe --contains HEAD 2>/dev/null)" || \
    branch="$(git name-rev --name-only --no-undefined --always HEAD 2>/dev/null)"
    [ -z "$branch" ] || echo "  $branch"
}

PROMPT_DIRTRIM=2
if [ "$color_prompt" = yes ]; then
    PS1='\[\033]133;A\033\\\]''\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[01;33m\]$(parse_git_branch)\[\033[00m\]\$ '
else
    PS1='\[\033]133;A\033\\\]''\u@\h:\w$(parse_git_branch)\$ '
fi
unset color_prompt force_color_prompt

# Enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
#if ! shopt -oq posix; then
#  if [ -f /usr/share/bash-completion/bash_completion ]; then
#    . /usr/share/bash-completion/bash_completion
#  elif [ -f /etc/bash_completion ]; then
#    . /etc/bash_completion
#  fi
#fi

# Aliases, functions and zoxide
source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/aliases"
source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/functions"
source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/bash-dirhistory"
command -v lf &> /dev/null && bind '"\C-o":"\C-u\C-klf\C-m"'
command -v zoxide &> /dev/null && eval "$(zoxide init bash)"

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
