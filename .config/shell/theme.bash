# a bash theme inspired by agnoster's theme

PROMPT_SEPARATOR=${PROMPT_SEPARATOR-$'\ue0b0'}
PROMPT_PLUSMINUS=${PROMPT_PLUSMINUS-$'\u00b1'}
PROMPT_BRANCH=${PROMPT_BRANCH-$'\ue0a0'}
PROMPT_CONTEXT_BG=${PROMPT_CONTEXT_BG:-253}
PROMPT_DIRTRIM=${PROMPT_DIRTRIM:-2}

prompt_segment() {
    if [ "$CURRENT_BG" = "NONE" ]; then
        printf '%s' "\[\033[0;38;5;${1};48;5;${2}m\]${3}"
    else
        printf '%s' "\[\033[0;38;5;${CURRENT_BG};48;5;${2}m\]${PROMPT_SEPARATOR}\[\033[38;5;${1}m\]${3}"
    fi
    CURRENT_BG=$2
}

prompt_context() {
    prompt_segment 0 $PROMPT_CONTEXT_BG " \u@\h "
}

prompt_virtualenv() {
    [ -z "$VIRTUAL_ENV" ] || prompt_segment 0 6 " ${VIRTUAL_ENV##*/} "
}

prompt_dir() {
    prompt_segment 254 4 " \[\033[1m\]\w "
}

prompt_git() {
    local bg=2 branch=''
    branch="$(git symbolic-ref --short HEAD 2>/dev/null)" || \
    branch="tags/$(git describe --tags --exact-match HEAD 2>/dev/null)" || \
    branch="$(git describe --contains HEAD 2>/dev/null)" || \
    branch="$(git name-rev --name-only --no-undefined --always HEAD 2>/dev/null)"
    if [ -n "$branch" ]; then
        branch="$branch "
        if [ -n "$(git status --porcelain --ignore-submodules -uno 2>/dev/null)" ]; then
            bg=3
            branch="${branch}${PROMPT_PLUSMINUS}"
        fi
        prompt_segment 0 $bg " $PROMPT_BRANCH${PROMPT_BRANCH:+ }$branch"
    fi
}

prompt_end() {
    printf '%s' "\[\033[0;38;5;${CURRENT_BG}m\]${PROMPT_SEPARATOR}"
}

prompt_main() {
    CURRENT_BG='NONE'
    prompt_context
    prompt_virtualenv
    prompt_dir
    prompt_git
    prompt_end
}

prompt_precmd() {
    PS1='\[\033]133;A\007\]'$(prompt_main)'\[\033[0m\] '
}

export PROMPT_COMMAND="${PROMPT_COMMAND:-}${PROMPT_COMMAND:+";"}prompt_precmd"
