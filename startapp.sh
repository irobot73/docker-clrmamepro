#!/usr/bin/env sh
#shellcheck shell=sh
# https://www.shellcheck.net/

# Uncomment below to show output of script
#set -xe

# https://gitlab.winehq.org/wine/wine/-/wikis/Debug-Channels
#WINEDEBUG=fixme-all,+module

HOME=/config
export HOME

mkdir -p $HOME/.wine

# If .INI doesn't exist, create one so the window doesn't minimize
# https://mamedev.emulab.it/clrmamepro/#docs
if [ ! -e /opt/clrmamepro/cmpro.ini ]; then
    printf "[CMPRO SETTINGS]\nAdv_HideWindow = off" >> /opt/clrmamepro/cmpro.ini
fi

# Launch clrmamepro
wine /opt/clrmamepro/cmpro64.exe 2>&1 | awk -W Interactive '{print "[clrmamepro] " $0}'
