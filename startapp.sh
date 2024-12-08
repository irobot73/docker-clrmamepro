#!/usr/bin/env sh
# https://www.shellcheck.net/
#shellcheck shell=sh

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

# Uncomment one of the following to pause the APP if you wish to console in & check/test your DOCKERFILE
#sleep infinity
#while :; do sleep 2073600; done # /bin/sleep is capped at 24hrs

# Launch clrmamepro
wine /opt/clrmamepro/cmpro64.exe 2>&1 | awk -W Interactive '{print "[clrmamepro] " $0}'
