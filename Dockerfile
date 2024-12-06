# Build upon via https://github.com/mikenye/docker-clrmamepro

FROM jlesage/baseimage-gui:ubuntu-24.04-v4.6.5

# https://en.wikipedia.org/wiki/Chmod
ARG MODE=755

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
    # Create basic .INI - should be using a VOLUME/BIND to persist
    touch /opt/clrmamepro/cmpro.ini && \
    printf "[CMPRO SETTINGS]\nAdv_HideWindow = off" > /opt/clrmamepro/cmpro.ini && \
    # Set perms
    take-ownership /opt/clrmamepro && \
    chmod +x /opt/clrmamepro/*.exe && \
    # Clean up
    apt-get remove -y \
        ca-certificates \
        curl \
        && \
    apt-get autoremove -y && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/* /tmp/*
