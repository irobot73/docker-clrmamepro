#! /bin/bash

set -eu
# Uncomment below to show output of script
#set -x

# Wine install - https://gitlab.winehq.org/wine/wine/-/wikis/Debian-Ubuntu
mkdir -pm755 /etc/apt/keyrings

wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/noble/winehq-noble.sources

apt-get update
apt-get install -y --install-recommends winehq-devel
