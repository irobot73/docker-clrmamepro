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

# How do I launch native applications from a Windows application?
#  https://stackoverflow.com/a/45545068
#    https://wiki.winehq.org/FAQ#How_do_I_launch_native_applications_from_a_Windows_application.3F
regKey='HKLM\System\CurrentControlSet\Control\Session Manager\Environment'
pathext_orig=$( wine reg query "$regKey" /v PATHEXT | tr -d '\r' | awk '/^  /{ print $3 }' )
echo "$pathext_orig" | grep -qE '(^|;)\.(;|$)' || wine reg add "$regKey" /v PATHEXT /f /d "${pathext_orig};."

INIFILE=/opt/clrmamepro/cmpro.ini

# If .INI doesn't exist, create one so the window doesn't minimize
    #   https://mamedev.emulab.it/clrmamepro/#docs
if [ -e "$INIFILE" ] && [ ! -s "$INIFILE" ]; then # Fil exists and is empty
    echo 'Initializing .INI file.'
    printf "[CMPRO SETTINGS]\nAdv_HideWindow = off" > $INIFILE
elif [ ! -e "$FILE" ]; then # File does NOT exist (should NEVER happen)
    echo 'Creating and initializing .INI file.'
    touch $INIFILE
    printf "[CMPRO SETTINGS]\nAdv_HideWindow = off" > $INIFILE
else
    echo 'Utilizing existing .INI file.'
fi
chown -R $USER_ID:$GROUP_ID $INIFILE


# Launch clrmamepro
wine /opt/clrmamepro/cmpro64.exe 2>&1 | awk -W Interactive '{print "[clrmamepro] " $0}'
