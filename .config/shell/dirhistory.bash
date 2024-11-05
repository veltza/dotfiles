# Directory history for Bash and optional zoxide
#
# Usage
# cd -num     (go to num directory)
# cd -        (go to previous directory)
# cdi dirname (cd command with interactive selection - requires zoxide)

function cd()
{
    __dirhistory_cdi=
    __dirhistory_cd "$@"
}

function cdi()
{
    __dirhistory_cdi=-i
    __dirhistory_cd "$@"
}

function __dirhistory_cd() 
{ 
    local stacksize=10
    local opts='' new_dir='' dir='' cnt=1
    while [[ "${1:-}" =~ ^-(L|P|e|@)+$ ]]; do
        opts="$opts $1"
        shift
    done
    if [ $# -eq 1 ] && [ "$1" = "-" ]; then
        new_dir=$OLDPWD
    elif [ $# -eq 1 ] && [[ "$1" =~ ^-[0-9]{1,2}$ ]]; then
        new_dir=$(dirs -l +${1:1}) || return
    else
        [ "${1:-}" = "--" ] && shift
        if [ $# -eq 0 ] && [ -z "$__dirhistory_cdi" ]; then
            new_dir=$HOME
        elif [ $# -eq 1 ] && [ -d "$1" ]; then
            new_dir=$1
        elif command -v zoxide &> /dev/null; then
            new_dir=$(zoxide query $__dirhistory_cdi -- "$@") || return
        else
            new_dir=$1
        fi
    fi
    pushd -n -- "$PWD" > /dev/null || return
    if builtin cd $opts -- "$new_dir"; then
        while dir=$(dirs -l +$cnt 2> /dev/null); do
            if [ "$dir" = "$PWD" ]; then
                popd -n +$cnt > /dev/null
                continue
            fi
            let cnt++
        done
        popd -n +$stacksize &> /dev/null
        return 0
    else
        popd -n +1 &> /dev/null
        return 1
    fi
}
