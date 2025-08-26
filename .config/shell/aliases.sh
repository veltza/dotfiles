if command -v bat &>/dev/null; then
    alias bat='bat -p'
    alias -g -- --help='--help | bat --language=help --style=plain' 2>/dev/null
fi
alias bc="bc -l ${XDG_CONFIG_HOME:-$HOME/.config}/bc/bcrc"
alias cal='cal -mw' && command -v ncal >/dev/null && alias cal='ncal -Mwb'
alias cd-='cd -'
alias cd..='cd ../'
alias ..='cd ../'
alias ...='cd ../../'
alias ....='cd ../../../'
alias .....='cd ../../../../'
alias -- -='cd -'
alias 1='cd -1'
alias 2='cd -2'
alias 3='cd -3'
alias 4='cd -4'
alias 5='cd -5'
alias 6='cd -6'
alias 7='cd -7'
alias 8='cd -8'
alias 9='cd -9'
alias cp='cp -i'
alias df='df -h'
alias d='dirs -v'
if diff --color=always /dev/null /dev/null &>/dev/null; then
    if diff --palette="" /dev/null /dev/null &>/dev/null; then
        alias diff='diff --color=always --palette=":ad=32;1:de=31;1"'
    else
        alias diff='diff --color=always'
    fi
fi
alias dotfiles="git --git-dir=$HOME/.dotfiles --work-tree=$HOME"
alias fd='fd --hyperlink'
alias fdi='find 2>/dev/null . -type d -iname'
alias ffi='find 2>/dev/null . -type f -iname'
alias Fdi='find 2>/dev/null . -type d -name'
alias Ffi='find 2>/dev/null . -type f -name'
alias free='free -h'
alias gau='git add --update'
alias gb='git branch'
alias gba='git branch --all'
alias gc='git commit'
alias gd='git diff'
alias gds='git diff --staged'
alias glg='git log --stat'
alias glgp='git log --patch'
alias glol='git log --graph --pretty="%C(yellow)%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset"'
alias glola='git log --graph --pretty="%C(yellow)%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset" --all'
alias gst='git status'
grep --color=auto colortest <<< "colortest" &>/dev/null && alias grep='grep --color=auto'
alias h="history${ZSH_VERSION+ 1}"
alias hs="history${ZSH_VERSION+ 1} | grep -i"
alias hsc="history${ZSH_VERSION+ 1} | grep"
alias ip='ip -color=auto'
if command -v gls &>/dev/null; then
    alias ls='gls --group-directories-first --color=auto'
elif ls --group-directories-first --color=auto &>/dev/null; then
    alias ls='ls --group-directories-first --color=auto'
fi
alias l='ls -lFh'
alias la='ls -A'
alias ll='ls -alFh'
alias lt='ls -lFhtr'
alias ldot='ls -ld .*'
alias mv='mv -i'
alias ncal='ncal -bMw'
alias rm='rm -i'
alias trl='trash-list'
alias trm='trash-put'
alias trr='trash-restore'
alias v='nvim'
