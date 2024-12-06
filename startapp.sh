#!/usr/bin/env sh
#shellcheck shell=sh
# https://www.shellcheck.net/

# Uncomment below to show output of script
set -xe

# https://gitlab.winehq.org/wine/wine/-/wikis/Debug-Channels
#WINEDEBUG=fixme-all,+module

HOME=/config
export HOME

mkdir -p $HOME/.wine

# How do I launch native applications from a Windows application?
#  https://stackoverflow.com/a/45545068
#    https://wiki.winehq.org/FAQ#How_do_I_launch_native_applications_from_a_Windows_application.3F
regKey='HKLM\System\CurrentControlSet\Control\Session Manager\Environment'
pathext_orig=$( wine reg query "$regKey" /v PATHEXT | tr -d '\r' | awk '/^  /{ print $3 }' )
echo "$pathext_orig" | grep -qE '(^|;)\.(;|$)' || wine reg add "$regKey" /v PATHEXT /f /d "${pathext_orig};."

INIFILE=/opt/clrmamepro/cmpro.ini

# File doesn't exist (should never happen)
if [[ ! -e $INIFILE ]]; then
    # If .INI doesn't exist, create one so the window doesn't minimize
    #   https://mamedev.emulab.it/clrmamepro/#docs
    echo 'Creating .INI file.'
    printf "[CMPRO SETTINGS]\nAdv_HideWindow = off" > $INIFILE
fi
# .INI exists but empty (0-bytes) or just white-spaces
if [[ -z $(grep '[^[:space:]]' $INIFILE) ]]; then
    echo 'Initializing .INI file.'
    printf "[CMPRO SETTINGS]\nAdv_HideWindow = off" > $INIFILE
fi
chown -R $USER_ID:$GROUP_ID $INIFILE


# Launch clrmamepro
wine /opt/clrmamepro/cmpro64.exe 2>&1 | awk -W Interactive '{print "[clrmamepro] " $0}'
