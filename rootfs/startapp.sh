#! /bin/bash
# https://www.shellcheck.net/

source /opt/scripts/clrmamepro.sh

set -eu
# Uncomment below to show output of script
#set -x

app="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Replace any missing a/o old file(s)
extract_mame /opt/app_src/mame.exe /opt/clrmamepro
unzip_clrmamepro /opt/app_src/cmpro.zip /opt/clrmamepro
setup_ini_file /opt/clrmamepro/cmpro.ini

# Do this last as we want (possible) latest versions
#   that won't be over-written in any process above'
cp --update /opt/app_src/*.exe /opt/clrmamepro/

chown "$USER_ID":"$GROUP_ID" /opt/clrmamepro
chmod +x /opt/clrmamepro/*.exe

# https://gitlab.winehq.org/wine/wine/-/wikis/Debug-Channels
#WINEDEBUG=fixme-all,+module
WINEDEBUG=-all,fixme-all

HOME=/config
export HOME

mkdir -p $HOME/.wine

# Uncomment one of the following to pause the APP if you wish to console in & check/test your DOCKERFILE
#sleep infinity
#while :; do sleep 2073600; done # /bin/sleep is capped at 24hrs

# How do I launch native applications from a Windows application?
#  https://stackoverflow.com/a/45545068
#    https://wiki.winehq.org/FAQ#How_do_I_launch_native_applications_from_a_Windows_application.3F
regKey='HKLM\System\CurrentControlSet\Control\Session Manager\Environment'
pathext_orig=$( wine reg query "$regKey" /v PATHEXT | tr -d '\r' | awk '/^  /{ print $3 }' )
echo "$pathext_orig" | grep -qE '(^|;)\.(;|$)' || wine reg add "$regKey" /v PATHEXT /f /d "${pathext_orig};."

# Launch clrmamepro
wine /opt/clrmamepro/cmpro64.exe 2>&1 | awk -W Interactive '{print "[clrmamepro] " $0}'
