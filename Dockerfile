# 1) Pull code from Github
# 2) Tweak/update
# 3) Build locally:  docker build --no-cache -t clrmamepro:latest .
# 4) Run locally:    docker run --rm --name clrmamepro -p 5800:5800 clrmamepro:latest

# Built upon via https://github.com/mikenye/docker-clrmamepro
FROM jlesage/baseimage-gui:ubuntu-24.04-v4.6.5

# https://en.wikipedia.org/wiki/Chmod
ARG MODE=555
ARG INIFILE=/opt/clrmamepro/cmpro.ini

# https://docs.docker.com/reference/dockerfile/#copy
COPY --chmod=$MODE startapp.sh /startapp.sh

# https://docs.docker.com/reference/dockerfile/#workdir
WORKDIR /opt/clrmamepro

COPY /apps/* /opt/clrmamepro/

RUN set -x && \
    set-cont-env APP_NAME "clrmamepro" && \
    # Update image and pull dependencies
    dpkg --add-architecture i386 && \ 
    apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        nano \
        p7zip-full \
        p7zip-rar \
        unzip \
        wget \
        zip \
        && \
    # Wine install - https://gitlab.winehq.org/wine/wine/-/wikis/Debian-Ubuntu
    mkdir -pm755 /etc/apt/keyrings && \
    wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key && \
    wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/noble/winehq-noble.sources && \
    apt-get update && \
    apt-get install -y --install-recommends winehq-devel && \
    # Find latest clrmamepro
    CMP_LATEST_BINARY=$( \
        curl https://mamedev.emulab.it/clrmamepro/ | \
        sed -n 's/.*href="\([^"]*\).*/\1/p' | \
        grep -i binaries | \
        grep -i cmp | \
        grep -i _64.zip | \
        sort -r | \
        head -1 \
        ) && \
    # Install clrmamepro
    curl -o /tmp/cmp.zip "https://mamedev.emulab.it/clrmamepro/$CMP_LATEST_BINARY" && \
    unzip /tmp/cmp.zip -d /opt/clrmamepro/ && \
    # Create .INI, in case not utilized during RUN
    touch $INIFILE && \
    printf "[CMPRO SETTINGS]\nAdv_HideWindow = off" > $INIFILE && \
    # Set perms
    chmod 666 $INIFILE && \
    take-ownership /opt/clrmamepro && \
    chmod +x /opt/clrmamepro/*.exe && \
    # Clean up
    apt-get remove -y \
        ca-certificates \
        && \
    apt-get autoremove -y && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/* /tmp/*
