#     ____      ____
#    / __/___  / __/
#   / /_/_  / / /_
#  / __/ / /_/ __/
# /_/   /___/_/ key-bindings.zsh
#
# - $FZF_TMUX_OPTS
# - $FZF_CTRL_T_COMMAND
# - $FZF_CTRL_T_OPTS
# - $FZF_CTRL_R_OPTS
# - $FZF_ALT_C_COMMAND
# - $FZF_ALT_C_OPTS

# Key bindings
# ------------

# The code at the top and the bottom of this file is the same as in completion.zsh.
# Refer to that file for explanation.
if 'zmodload' 'zsh/parameter' 2>'/dev/null' && (( ${+options} )); then
  __fzf_key_bindings_options="options=(${(j: :)${(kv)options[@]}})"
else
  () {
    __fzf_key_bindings_options="setopt"
    'local' '__fzf_opt'
    for __fzf_opt in "${(@)${(@f)$(set -o)}%% *}"; do
      if [[ -o "$__fzf_opt" ]]; then
        __fzf_key_bindings_options+=" -o $__fzf_opt"
      else
        __fzf_key_bindings_options+=" +o $__fzf_opt"
      fi
    done
  }
fi

'emulate' 'zsh' '-o' 'no_aliases'

{

[[ -o interactive ]] || return 0

# CTRL-T - Paste the selected file path(s) into the command line
__fsel() {
  if [ "$PWD" = "$HOME" ]; then
    if command -v fd &>/dev/null; then
      local cmd="${FZF_CTRL_T_COMMAND:-"command fd --max-depth=4 --follow -H -E .backups -E .cache -E .git -E .mozilla -E .thunderbird -E .windows"}"
    else
      local cmd="${FZF_CTRL_T_COMMAND:-"command find -L . -maxdepth 4 \\( -path '*/.git' -o -name '.gitignore' -o -path './.backups' -o -path './.cache' -o -path './.mozilla' -o -path './.thunderbird' -o -path './.windows' \
        -o -fstype 'sysfs' -o -fstype 'devfs' -o -fstype 'devtmpfs' -o -fstype 'proc' \\) -prune -o -print 2> /dev/null | cut -b3-"}"
    fi
  elif printf '%s' "$PWD" | grep -q $HOME; then
    if command -v fd &>/dev/null; then
      local cmd="${FZF_CTRL_T_COMMAND:-"command fd --follow -H -E .git"}"
    else
      local cmd="${FZF_CTRL_T_COMMAND:-"command find -L . \\( -path '*/.git' -o -name '.gitignore' -o -fstype 'sysfs' -o -fstype 'devfs' -o -fstype 'devtmpfs' -o -fstype 'proc' \\) -prune \
        -o -print 2> /dev/null | cut -b3-"}"
    fi
  else
    local cmd="${FZF_CTRL_T_COMMAND:-"command find . -maxdepth 2 \\( -path '*/.git' -o -name '.gitignore' -o -fstype 'sysfs' -o -fstype 'devfs' -o -fstype 'devtmpfs' -o -fstype 'proc' \\) -prune \
      -o -print 2> /dev/null | cut -b3-"}"
  fi
  setopt localoptions pipefail no_aliases 2> /dev/null
  local item
  eval "$cmd" | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse --bind=ctrl-z:ignore $FZF_DEFAULT_OPTS $FZF_CTRL_T_OPTS" $(__fzfcmd) -m "$@" | while read item; do
    echo -n "${(q)item} "
  done
  local ret=$?
  echo
  return $ret
}

__fzfcmd() {
  [ -n "$TMUX_PANE" ] && { [ "${FZF_TMUX:-0}" != 0 ] || [ -n "$FZF_TMUX_OPTS" ]; } &&
    echo "fzf-tmux ${FZF_TMUX_OPTS:--d${FZF_TMUX_HEIGHT:-40%}} -- " || echo "fzf"
}

fzf-file-widget() {
  LBUFFER="${LBUFFER}$(__fsel)"
  local ret=$?
  zle reset-prompt
  return $ret
}
zle     -N   fzf-file-widget
bindkey '^T' fzf-file-widget

# ALT-C - cd into the selected directory
fzf-cd-widget() {
  if [ "$PWD" = "$HOME" ]; then
    if command -v fd &>/dev/null; then
      local cmd="${FZF_CTRL_T_COMMAND:-"command fd -td --max-depth=4 --follow -H -E .backups -E .cache -E .git -E .mozilla -E .thunderbird -E .windows"}"
    else
      local cmd="${FZF_CTRL_T_COMMAND:-"command find -L . -maxdepth 4 \\( -path '*/.git' -o -name '.gitignore' -o -path './.backups' -o -path './.cache' -o -path './.mozilla' -o -path './.thunderbird' -o -path './.windows' \
        -o -fstype 'sysfs' -o -fstype 'devfs' -o -fstype 'devtmpfs' -o -fstype 'proc' \\) -prune -o -type d -print 2> /dev/null | cut -b3-"}"
    fi
  elif printf '%s' "$PWD" | grep -q $HOME; then
    if command -v fd &>/dev/null; then
      local cmd="${FZF_CTRL_T_COMMAND:-"command fd -td --follow -H -E .git"}"
    else
      local cmd="${FZF_CTRL_T_COMMAND:-"command find -L . \\( -path '*/.git' -o -name '.gitignore' -o -fstype 'sysfs' -o -fstype 'devfs' -o -fstype 'devtmpfs' -o -fstype 'proc' \\) -prune \
        -o -type d -print 2> /dev/null | cut -b3-"}"
    fi
  else
    local cmd="${FZF_ALT_C_COMMAND:-"command find . -maxdepth 2 \\( -path '*/.git' -o -name '.gitignore' -o -fstype 'sysfs' -o -fstype 'devfs' -o -fstype 'devtmpfs' -o -fstype 'proc' \\) -prune \
      -o -print 2> /dev/null | cut -b3-"}"
  fi
  setopt localoptions pipefail no_aliases 2> /dev/null
  local dir="$(eval "$cmd" | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse --bind=ctrl-z:ignore $FZF_DEFAULT_OPTS $FZF_ALT_C_OPTS" $(__fzfcmd) +m)"
  if [[ -z "$dir" ]]; then
    zle redisplay
    return 0
  fi
  [ -f "$dir" ] && dir=$(dirname $dir)
  zle push-line # Clear buffer. Auto-restored on next prompt.
  BUFFER="cd ${(q)dir}"
  zle accept-line
  local ret=$?
  unset dir # ensure this doesn't end up appearing in prompt expansion
  zle reset-prompt
  return $ret
}
zle     -N    fzf-cd-widget
bindkey '\ec' fzf-cd-widget

# CTRL-R - Paste the selected command from history into the command line
fzf-history-widget() {
  local selected num
  setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases 2> /dev/null
  selected=( $(fc -rl 1 | perl -ne 'print if !$seen{(/^\s*[0-9]+\**\s+(.*)/, $1)}++' |
    FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} $FZF_DEFAULT_OPTS -n2..,.. --tiebreak=index --bind=ctrl-r:toggle-sort,ctrl-z:ignore $FZF_CTRL_R_OPTS --query=${(qqq)LBUFFER} +m" $(__fzfcmd)) )
  local ret=$?
  if [ -n "$selected" ]; then
    num=$selected[1]
    if [ -n "$num" ]; then
      zle vi-fetch-history -n $num
    fi
  fi
  zle reset-prompt
  return $ret
}
zle     -N   fzf-history-widget
bindkey '^R' fzf-history-widget

} always {
  eval $__fzf_key_bindings_options
  'unset' '__fzf_key_bindings_options'
}
