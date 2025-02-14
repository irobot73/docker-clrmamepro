# 1) Pull code from Github
# 2) Tweak/update
# 3) Build locally:  docker build --no-cache -t clrmamepro:latest .
# 4) Run locally:    docker run --rm --name clrmamepro -p 5800:5800 clrmamepro:latest

# Built upon via https://github.com/mikenye/docker-clrmamepro
#   Which was built upon via https://github.com/jlesage/docker-baseimage-gui
FROM jlesage/baseimage-gui:ubuntu-24.04-v4.6.5

ARG CMPRO_DIR=/opt/clrmamepro
ARG SCRIPT_DIR=/opt/scripts
ARG SOURCE_DIR=/opt/app_src

# https://docs.docker.com/reference/dockerfile/#workdir
WORKDIR $CMPRO_DIR

# https://docs.docker.com/reference/dockerfile/#copy
COPY rootfs/ /

RUN set -x && \
    set-cont-env APP_NAME "clrmamepro" && \
# Set Pre-perms
    take-ownership $SCRIPT_DIR && \
    take-ownership $SOURCE_DIR && \
    # https://chmod-calculator.com/
    chmod +x /startapp.sh && \
    chmod +x $SCRIPT_DIR/*.sh && \
    chmod 666 $SCRIPT_DIR/*.txt && \
    chmod 555 $SOURCE_DIR/*.exe && \
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
    $SCRIPT_DIR/install_wine.sh && \
# Get latest MAME
    $SCRIPT_DIR/clrmamepro.sh get_mame $SOURCE_DIR/mame.exe && \
# Extract MAME binaries
#   Update, as needed, the file in 'rootfs/opt/scripts'
    $SCRIPT_DIR/clrmamepro.sh extract_mame $SOURCE_DIR/mame.exe $CMPRO_DIR && \
# Get latest clrmamepro
    # <script_file> <function> <parameter(s)>
    $SCRIPT_DIR/clrmamepro.sh get_clrmamepro $SOURCE_DIR/cmpro.zip && \
# Uncompress clrmamepro
    $SCRIPT_DIR/clrmamepro.sh unzip_clrmamepro $SOURCE_DIR/cmpro.zip $CMPRO_DIR && \
# Create .INI, in case not utilized during RUN
    $SCRIPT_DIR/clrmamepro.sh setup_ini_file /opt/clrmamepro/cmpro.ini && \
# Set final perms
    take-ownership $CMPRO_DIR && \
    chmod +x $CMPRO_DIR/*.exe && \
# Clean up
    apt-get remove -y \
        ca-certificates \
        && \
    apt-get autoremove -y && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/* /tmp/*
