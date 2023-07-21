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

# Fixing paths
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export GTK2_RC_FILES="$XDG_CONFIG_HOME/gtk-2.0/gtkrc"
export INPUTRC="$XDG_CONFIG_HOME/shell/inputrc"
export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/ripgrep/ripgreprc"

# Default apps
export EDITOR=lvim
export SUDO_EDITOR=lvim
export BROWSER=chromium

# Less Colors for Man Pages
export LESS_TERMCAP_mb=$(printf '\33[01;31m')    # begin blinking
export LESS_TERMCAP_md=$(printf '\33[01;36m')    # begin bold
export LESS_TERMCAP_me=$(printf '\33[0m')        # end mode
export LESS_TERMCAP_so=$(printf '\33[01;47;34m') # begin standout-mode - info box
export LESS_TERMCAP_se=$(printf '\33[0m')        # end standout-mode
export LESS_TERMCAP_us=$(printf '\33[01;32m')    # begin underline
export LESS_TERMCAP_ue=$(printf '\33[0m')        # end underline

# Less settings
export LESSUTFCHARDEF=E000-F8FF:p,F0000-FFFFD:p,100000-10FFFD:p
export LESSHISTFILE=-
export LESS="-R"

# Increase the font size from 10 pt to 10.5 pt in QT apps.
export QT_FONT_DPI=98
export QT_QPA_PLATFORMTHEME=qt5ct

# ls colors
[ -f "$XDG_CONFIG_HOME/shell/dircolors" ] && . "$XDG_CONFIG_HOME/shell/dircolors"
