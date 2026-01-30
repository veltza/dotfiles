# Report the current working directory to the terminal
update_terminal_cwd() {
    # window title
    local title=$PWD
    case "$title" in
        $HOME) title=$USER ;;
        $HOME*) title="~${title#$HOME}" ;;
    esac
    printf "\033]0;%s\007" "$title"
    # current working directory
    if [ -n "${WSL_DISTRO_NAME:-}" ]; then
        printf "\033]9;9;%s\007" "$PWD"
    elif [ -n "${WT_SESSION:-}" ]; then
        printf "\033]9;9;%s\007" "$(cygpath -w "$PWD")"
    else
        printf "\033]7;file://%s%s\007" "$(hostname)" "$(urlencode_cwd)"
    fi
}

urlencode_cwd() {
    printf '%s' "$PWD" | perl -lpe 's/([^A-Za-z0-9-.\/:_!\(\)~'"\'"'])/sprintf("%%%02X", ord($1))/seg'
}

# Alias for lf
lf() {
    rm -f "${XDG_RUNTIME_DIR:-$XDG_CACHE_HOME}/lf-last-dir-path"
    command lf -last-dir-path="${XDG_RUNTIME_DIR:-$XDG_CACHE_HOME}/lf-last-dir-path" "$@" && cdlf
    update_terminal_cwd
}

# Change working dir in shell to last dir in lf
cdlf() {
    local dir=$(cat "${XDG_RUNTIME_DIR:-$XDG_CACHE_HOME}/lf-last-dir-path" 2>/dev/null)
    [ "$dir" = "$(pwd)" ] || [ -d "$dir" ] && cd "$dir"
}

# Alias for yazi
y() {
    command yazi "$@" --cwd-file="${XDG_RUNTIME_DIR:-$XDG_CACHE_HOME}/yazi-cwd-file" && cdy
    update_terminal_cwd
}

# Change working dir in shell to last dir in yazi
cdy() {
    local dir=$(cat "${XDG_RUNTIME_DIR:-$XDG_CACHE_HOME}/yazi-cwd-file" 2>/dev/null)
    [ "$dir" = "$(pwd)" ] || [ -d "$dir" ] && cd "$dir"
}

# tmux wrapper
tm() {
    if [ $# -gt 0 ]; then
        tmux "$@"
    elif tmux ls 2> /dev/null | grep -vq attached; then
        tmux attach-session
    else
        tmux new-session
    fi
    update_terminal_cwd
}

# Toggle side-by-side view in the delta pager
delta-toggle() {
    local sbs=${DELTA_FEATURES:-'+'}
    [ $sbs = '+' ] && sbs=+side-by-side || sbs=+
    export DELTA_FEATURES=$sbs
}

# Run the system update in a tmux session
update() {
    if [ -n "${TMUX:-}" ] || [ "$(uname -o 2>/dev/null)" = 'Msys' ]; then
        system-update
    elif tmux has-session -t 'Update' 2> /dev/null; then
        tmux attach-session -t 'Update' \; new-window \; send-keys "system-update" C-m
    else
        tmux new-session -s 'Update' \; send-keys "system-update" C-m
    fi
    update_terminal_cwd
}

system-update() {
    if command -v yay &>/dev/null; then
        yay -Pw 2>/dev/null; yay
    elif command -v pacman &>/dev/null; then
        sudo pacman -Syu
    elif command -v aupdate &>/dev/null; then
        aupdate
    elif command -v apt &>/dev/null; then
        sudo apt update && sudo apt upgrade
    elif command -v pkg &>/dev/null; then
        doas pkg upgrade && doas freebsd-update fetch install && doas pkg clean -q -y
    elif command -v pkg_add &>/dev/null; then
        doas pkg_add -u && doas syspatch
    fi
}

# Use fd (https://github.com/sharkdp/fd) instead of the default find
# command for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
    if command -v fd &>/dev/null; then
        fd --follow -H -E .git . "$1"
    else
        echo "$1"
        command find -L "$1" \
          -name .git -prune -o -name .hg -prune -o -name .svn -prune -o \( -type d -o -type f -o -type l \) \
          -a -not -path "$1" -print 2> /dev/null | sed 's@^\./@@'
    fi
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
    if command -v fd &>/dev/null; then
        fd -td --follow -H -E .git . "$1"
    else
        command find -L "$1" \
          -name .git -prune -o -name .hg -prune -o -name .svn -prune -o -type d \
          -a -not -path "$1" -print 2> /dev/null | sed 's@^\./@@'
    fi
}
