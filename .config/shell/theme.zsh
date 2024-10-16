# a zsh theme inspired by agnoster's theme

PROMPT_SEPARATOR=${PROMPT_SEPARATOR-"\ue0b0"}
PROMPT_PLUSMINUS=${PROMPT_PLUSMINUS-"\u00b1"}
PROMPT_ELLIPSIS=${PROMPT_ELLIPSIS-"…"}
PROMPT_BRANCH=${PROMPT_BRANCH-"\ue0a0"}
PROMPT_CONTEXT_BG=${PROMPT_CONTEXT_BG:-253}

prompt_segment() {
    local fg="%{%F{$1}%}" bg="%{%K{$2}%}"
    if [ "$CURRENT_BG" = "NONE" ]; then
        print -n "${bg}${fg}${3}"
    else
        print -n "${bg}%{%F{$CURRENT_BG}%}${PROMPT_SEPARATOR}${fg}${3}"
    fi
    CURRENT_BG=$2
}

prompt_context() {
    prompt_segment black $PROMPT_CONTEXT_BG " %n@%m "
}

prompt_virtualenv() {
    [ -z "$VIRTUAL_ENV" ] || prompt_segment black cyan " ${VIRTUAL_ENV##*/} "
}

prompt_dir() {
    prompt_segment 254 blue " %B%(4~|%-1~/$PROMPT_ELLIPSIS/%2~|%~)%b "
}

prompt_git() {
    local bg=green branch="$vcs_info_msg_0_ "
    if [ -n "$vcs_info_msg_0_" ]; then
        if [ -n "$(git status --porcelain --ignore-submodules -uno 2>/dev/null)" ]; then
            bg=yellow
            branch="${branch}${PROMPT_PLUSMINUS}"
        fi
        prompt_segment black $bg " $PROMPT_BRANCH${PROMPT_BRANCH:+ }$branch"
    fi
}

prompt_end() {
    print -n "%k%{%F{$CURRENT_BG}%}${PROMPT_SEPARATOR}"
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
    vcs_info
    PROMPT=$'%{\e]133;A\a%}''%{%f%b%k%}$(prompt_main)%{%f%b%k%} '
}

prompt_setup() {
    autoload -Uz add-zsh-hook
    autoload -Uz vcs_info
    setopt prompt_subst
    zstyle ':vcs_info:*' enable git
    zstyle ':vcs_info:*' check-for-changes false
    zstyle ':vcs_info:git*' formats '%b'
    zstyle ':vcs_info:git*' actionformats '%b (%a)'
    add-zsh-hook precmd prompt_precmd
}

prompt_setup "$@"
