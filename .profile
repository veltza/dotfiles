# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# Set PATH so it includes user's private binary dirs if exists
[ -d "$HOME/Applications" ] && PATH="$HOME/Applications:$PATH"
[ -d "$HOME/bin" ] && PATH="$HOME/bin:$PATH"
[ -d "$HOME/.local/bin" ] && PATH="$HOME/.local/bin:$PATH"

# XDG paths
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
if [ -z "$XDG_RUNTIME_DIR" ]; then
    export XDG_RUNTIME_DIR="$XDG_CACHE_HOME/runtime"
    mkdir -m 700 -p "$XDG_RUNTIME_DIR"
fi

# App paths
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export GOPATH="$XDG_DATA_HOME/go"
export GTK2_RC_FILES="$XDG_CONFIG_HOME/gtk-2.0/gtkrc"
export INPUTRC="$XDG_CONFIG_HOME/shell/inputrc"
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export PYTHONSTARTUP="$XDG_CONFIG_HOME/python/pythonstartup.py"
export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/ripgrep/ripgreprc"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export WGETRC="$XDG_CONFIG_HOME/wget/wgetrc"

# Default apps
export VISUAL=nvim
export EDITOR=nvim
export SUDO_EDITOR=nvim
export BROWSER=chromium
export TERMINAL=st

# Less Colors for Man Pages
export LESS_TERMCAP_mb=$(printf '\33[01;31m')    # begin blinking
export LESS_TERMCAP_md=$(printf '\33[01;36m')    # begin bold
export LESS_TERMCAP_me=$(printf '\33[0m')        # end mode
export LESS_TERMCAP_so=$(printf '\33[01;47;34m') # begin standout-mode - info box
export LESS_TERMCAP_se=$(printf '\33[0m')        # end standout-mode
export LESS_TERMCAP_us=$(printf '\33[01;32m')    # begin underline
export LESS_TERMCAP_ue=$(printf '\33[0m')        # end underline
export MANROFFOPT="-c"
#export GROFF_NO_SGR=1

# Less settings
export LESSUTFCHARDEF=E000-F8FF:p,F0000-FFFFD:p,100000-10FFFD:p
export LESSHISTFILE="$XDG_RUNTIME_DIR/.lesshst"
export LESS="-R"

# Increase the font size from 10 pt to 10.5 pt in QT apps.
export QT_FONT_DPI=98
export QT_QPA_PLATFORMTHEME=qt5ct

# Make sure we have true colors when we ssh into this machine
[ -n "$SSH_CONNECTION" ] || [ -n "$SSH_TTY" ] && export COLORTERM=truecolor

# ls colors
[ ! -f "$XDG_CONFIG_HOME/shell/ls_colors.sh" ] || . "$XDG_CONFIG_HOME/shell/ls_colors.sh"

# Set locale
[ ! -f "$XDG_CONFIG_HOME/locale.conf" ] || . "$XDG_CONFIG_HOME/locale.conf"

# fcitx5
# export GTK_IM_MODULE=fcitx
# export QT_IM_MODULE=fcitx
# export XMODIFIERS=@im=fcitx
