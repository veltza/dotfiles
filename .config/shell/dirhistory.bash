# Directory history for Bash
#
# Usage
# cd dirname  (go to the given directory)
# cd -num     (go back to a visited directory)
# cd -        (go to the previous directory)
# cdi dirname (cd command with interactive selection - zoxide required)
#
# Set the directory history size (default is 10, if not set):
# DIRHISTORYSIZE=10
#
# If you initialize zoxide with "zoxide init bash --cmd cd", evaluate it before
# sourcing this script.

function cd()
{
    __dirhistory_cdi=
    __dirhistory_cd "$@"
}

function cdi()
{
    command -v zoxide &> /dev/null && __dirhistory_cdi=-i
    __dirhistory_cd "$@"
}

function __dirhistory_cd() 
{ 
    local stacksize=${DIRHISTORYSIZE:-10}
    local opts='' new_dir='' dir='' idx=1

    while [[ "${1:-}" =~ ^-(L|P|e|@)+$ ]]; do
        opts="$opts $1"
        shift
    done

    [[ "${1:-}" == "--" ]] && shift

    if [[ -n "${__dirhistory_cdi:-}" ]]; then
        new_dir=$(zoxide query -i -- "$@") || return
    elif [[ $# -eq 0 ]]; then
        new_dir=$HOME
    elif [[ $# -eq 1 ]] && [[ "$1" == "-" ]]; then
        new_dir=$OLDPWD
    elif [[ $# -eq 1 ]] && [[ "$1" =~ ^-[0-9]{1,2}$ ]]; then
        new_dir=$(dirs -l +${1:1}) || return
    elif [[ $# -eq 1 ]] && [[ -d "$1" ]]; then
        new_dir=$1
    elif command -v zoxide &> /dev/null; then
        new_dir=$(zoxide query -- "$@") || return
    elif [[ $# -gt 1 ]]; then
        echo "dirhistory: cd: too many arguments" >&2; return 2
    else
        new_dir=$1
    fi

    pushd -n -- "$PWD" > /dev/null || return
    if builtin cd $opts -- "$new_dir"; then
        while dir=$(dirs -l +$idx 2> /dev/null); do
            if [[ "$dir" == "$PWD" ]]; then
                popd -n +$idx > /dev/null
                continue
            fi
            ((idx++))
        done
        [[ $stacksize -lt 1 ]] && stacksize=1
        popd -n +$stacksize &> /dev/null
        return 0
    else
        popd -n +1 &> /dev/null
        return 1
    fi
}
