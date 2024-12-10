# irobot73/clrmamepro

Docker container for Clrmamepro

The GUI of the application is accessed through a modern web browser (no installation or configuration needed on client side) or via any VNC client.

---

[![Clrmamepro logo](https://mamedev.emulab.it/clrmamepro/logo.png)](https://mamedev.emulab.it/clrmamepro/)

Clrmamepro is a ROM organisation and management tool for Windows. This container runs it on Linux using Wine.

---

This container is based on the absolutely fantastic [jlesage/baseimage-gui](https://hub.docker.com/r/jlesage/baseimage-gui). All the hard work has been done by them, and I shamelessly copied their README.md too. I've cut the README.md down quite a bit, for advanced usage I suggest you check out the [README](https://github.com/jlesage/docker-handbrake/blob/master/README.md) from [jlesage/baseimage-gui](https://hub.docker.com/r/jlesage/baseimage-gui).

---

## Quick Start

**NOTE**: The Docker command provided in this quick start is given as an example
and parameters should be adjusted to your need.

Launch the Picard docker container with the following command:

```shell
docker run -d \
    -it \
    --restart=always \
    --name=clrmamepro \
    -p 5800:5800 \
    -v /path/to/clrmamepro/backup:/opt/clrmamepro/backup \
    -v /path/to/clrmamepro/datfiles:/opt/clrmamepro/datfiles \
    -v /path/to/clrmamepro/dir2dat:/opt/clrmamepro/dir2dat \
    -v /path/to/clrmamepro/downloads:/opt/clrmamepro/downloads \
    -v /path/to/clrmamepro/fastscans:/opt/clrmamepro/fastscans \
    -v /path/to/clrmamepro/headers:/opt/clrmamepro/headers \
    -v /path/to/clrmamepro/logs:/opt/clrmamepro/logs \
    -v /path/to/clrmamepro/scans:/opt/clrmamepro/scans \
    -v /path/to/clrmamepro/settings:/opt/clrmamepro/settings \
    -v /path/to/clrmamepro/roms:/opt/clrmamepro/roms \
    irobot73/docker-clrmamepro:master
```

Where:

* `/path/to/clrmamepro`: This is where the application stores its configuration, datfiles, roms and any other files needing persistency.

Browse to `http://your-host-ip:5800` to access the Picard GUI. The mounted volumes are located under `/opt/clrmamepro`.

### Environment Variables

To customize some properties of the container, the following environment
variables can be passed via the `-e` parameter (one for each variable).  Value
of this parameter has the format `<VARIABLE_NAME>=<VALUE>`.

| Variable       | Description                                  | Default |
|----------------|----------------------------------------------|---------|
|`USER_ID`| ID of the user the application runs as.  See [User/Group IDs](#usergroup-ids) to better understand when this should be set. | `1000` |
|`GROUP_ID`| ID of the group the application runs as.  See [User/Group IDs](#usergroup-ids) to better understand when this should be set. | `1000` |
|`SUP_GROUP_IDS`| Comma-separated list of supplementary group IDs of the application. | (unset) |
|`UMASK`| Mask that controls how file permissions are set for newly created files. The value of the mask is in octal notation.  By default, this variable is not set and the default umask of `022` is used, meaning that newly created files are readable by everyone, but only writable by the owner. See the following online umask calculator: <http://wintelguy.com/umask-calc.pl> | (unset) |
|`TZ`| [TimeZone] of the container.  Timezone can also be set by mapping `/etc/localtime` between the host and the container. | `Etc/UTC` |
|`KEEP_APP_RUNNING`| When set to `1`, the application will be automatically restarted if it crashes or if user quits it. | `0` |
|`APP_NICENESS`| Priority at which the application should run.  A niceness value of -20 is the highest priority and 19 is the lowest priority.  By default, niceness is not set, meaning that the default niceness of 0 is used.  **NOTE**: A negative niceness (priority increase) requires additional permissions.  In this case, the container should be run with the docker option `--cap-add=SYS_NICE`. | (unset) |
|`CLEAN_TMP_DIR`| When set to `1`, all files in the `/tmp` directory are delete during the container startup. | `1` |
|`DISPLAY_WIDTH`| Width (in pixels) of the application's window. | `1280` |
|`DISPLAY_HEIGHT`| Height (in pixels) of the application's window. | `768` |
|`SECURE_CONNECTION`| When set to `1`, an encrypted connection is used to access the application's GUI (either via web browser or VNC client).  See the [Security](#security) section for more details. | `0` |
|`VNC_PASSWORD`| Password needed to connect to the application's GUI.  See the [VNC Password](#vnc-password) section for more details. | (unset) |
|`X11VNC_EXTRA_OPTS`| Extra options to pass to the x11vnc server running in the Docker container.  **WARNING**: For advanced users. Do not use unless you know what you are doing. | (unset) |
|`ENABLE_CJK_FONT`| When set to `1`, open source computer font `WenQuanYi Zen Hei` is installed.  This font contains a large range of Chinese/Japanese/Korean characters. | `0` |

### Data Volumes

The following table describes data volumes used by the container.  The mappings
are set via the `-v` parameter.  Each mapping is specified with the following
format: `<HOST_DIR>:<CONTAINER_DIR>[:PERMISSIONS]`.

| Container path  | Permissions | Description |
|-----------------|-------------|-------------|
| `/opt/clrmamepro/backup`    | rw | CMPro places rom-backups here. |
| `/opt/clrmamepro/datfiles`  | rw | You should place your datfiles in this folder. |
| `/opt/clrmamepro/dir2dat`   | rw | You should place your dir2dat saved settings in this folder. |
| `/opt/clrmamepro/downloads` | rw | CMPro places downloads here. |
| `/opt/clrmamepro/fastscans` | rw | You should place your fastscans in this folder. |
| `/opt/clrmamepro/headers`   | rw | XML header files go in this folder. |
| `/opt/clrmamepro/logs`      | rw | You should place your logfiles in this folder. |
| `/opt/clrmamepro/scans`     | rw | CMPro places ScanResults here. |
| `/opt/clrmamepro/settings`  | rw | CMPro places SettingsFiles here. |
| `/opt/clrmamepro/roms`      | rw | Legally obtained ROMs go here. |

### Ports

Here is the list of ports used by the container.  They can be mapped to the host
via the `-p` parameter (one per port mapping).  Each mapping is defined in the
following format: `<HOST_PORT>:<CONTAINER_PORT>`.  The port number inside the
container cannot be changed, but you are free to use any port on the host side.

| Port | Mapping to host | Description |
|------|-----------------|-------------|
| 5800 | Mandatory | Port used to access the application's GUI via the web interface. |
| 5900 | Optional | Port used to access the application's GUI via the VNC protocol.  Optional if no VNC client is used. |

## Docker Compose File

Here is an example of a `docker-compose.yml` file that can be used with
[Docker Compose](https://docs.docker.com/compose/overview/).

Make sure to adjust according to your needs.  Note that only mandatory network
ports are part of the example.

```yaml
services:
  clrmamepro:
    image: ghcr.io/irobot73/docker-clrmamepro:master
    container_name: clrmamepro
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /etc/timezone:/etc/timezone:ro
      - /var/run/docker.sock:/var/run/docker.sock
# Container configuration(s)
      - ./config:/config
# Local substitutions
      - ./data/buttons:/opt/clrmamepro/buttons
      - ./data/dir2dat:/opt/clrmamepro/dir2dat
      - ./data/downloads:/opt/clrmamepro/downloads
      - ./data/fastscans:/opt/clrmamepro/fastscans
      - ./data/fixdats:/opt/clrmamepro/fixdats
      - ./data/hashes:/opt/clrmamepro/hashes
      - ./data/headers:/opt/clrmamepro/headers
      - ./data/lists:/opt/clrmamepro/lists
      - ./data/logs:/opt/clrmamepro/logs
      - ./data/scans:/opt/clrmamepro/scans
      - ./data/settings:/opt/clrmamepro/settings
      - ./data/temp:/opt/clrmamepro/temp
# Remote substitutions
      - /nas/Emu/backup:/opt/clrmamepro/backup
      - /nas/Emu/DATs:/opt/clrmamepro/datfiles
      - /nas/Emu/ROMs:/opt/clrmamepro/roms
      - /nas/Emu/2-Sort:/opt/clrmamepro/source
# Config file
      - ./data/cmpro.ini:/opt/clrmamepro/cmpro.ini
    environment:
      #- DARK_MODE=1
      - DISPLAY_WIDTH=1920
      - DISPLAY_HEIGHT=1080
      - GROUP_ID=1000
      - KEEP_APP_RUNNING=1
      - USER_ID=1000
    ports:
      - 5800:5800
```

## Docker Image Update

If the system on which the container runs doesn't provide a way to easily update
the Docker image, the following steps can be followed:

  1. Fetch the latest image:
```shell
irobot73/docker-clrmamepro:master
```
  2. Stop the container:
```shell
docker stop clrmamepro
```
  3. Remove the container:
```shell
docker rm clrmamepro
```
  4. Start the container using the `docker run` command:
```shell
docker run --rm --name clrmamepro -p 5800:5800 clrmamepro:latest
```

## User/Group IDs

When using data volumes (`-v` flags), permissions issues can occur between the
host and the container.  For example, the user within the container may not
exists on the host.  This could prevent the host from properly accessing files
and folders on the shared volume.

To avoid any problem, you can specify the user the application should run as.

This is done by passing the user ID and group ID to the container via the
`USER_ID` and `GROUP_ID` environment variables.

To find the right IDs to use, issue the following command on the host, with the
user owning the data volume on the host:

```shell
id <username>
```

Which gives an output like this one:

```text
uid=1000(myuser) gid=1000(myuser) groups=1000(myuser),4(adm),24(cdrom),27(sudo),46(plugdev),113(lpadmin)
```

The value of `uid` (user ID) and `gid` (group ID) are the ones that you should
be given the container.

## Accessing the GUI

Assuming that container's ports are mapped to the same host's ports, the
graphical interface of the application can be accessed via:

* A web browser:
  
```text
http://<HOST IP ADDR>:5800
```

* Any VNC client:

```text
<HOST IP ADDR>:5900
```

## Security

By default, access to the application's GUI is done over an unencrypted
connection (HTTP or VNC).

Secure connection can be enabled via the `SECURE_CONNECTION` environment
variable.  See the [Environment Variables](#environment-variables) section for
more details on how to set an environment variable.

When enabled, application's GUI is performed over an HTTPs connection when
accessed with a browser.  All HTTP accesses are automatically redirected to
HTTPs.

When using a VNC client, the VNC connection is performed over SSL.  Note that
few VNC clients support this method.  [SSVNC] is one of them.

[SSVNC]: http://www.karlrunge.com/x11vnc/ssvnc.html

### Certificates

Here are the certificate files needed by the container.  By default, when they
are missing, self-signed certificates are generated and used.  All files have
PEM encoded, x509 certificates.

| Container Path                  | Purpose                    | Content |
|---------------------------------|----------------------------|---------|
|`/config/certs/vnc-server.pem`   |VNC connection encryption.  |VNC server's private key and certificate, bundled with any root and intermediate certificates.|
|`/config/certs/web-privkey.pem`  |HTTPs connection encryption.|Web server's private key.|
|`/config/certs/web-fullchain.pem`|HTTPs connection encryption.|Web server's certificate, bundled with any root and intermediate certificates.|

**NOTE**: To prevent any certificate validity warnings/errors from the browser
or VNC client, make sure to supply your own valid certificates.

**NOTE**: Certificate files are monitored and relevant daemons are automatically
restarted when changes are detected.

### VNC Password

To restrict access to your application, a password can be specified.  This can
be done via two methods:

* By using the `VNC_PASSWORD` environment variable.
* By creating a `.vncpass_clear` file at the root of the `/config` volume.
  This file should contains the password in clear-text.  During the container
  startup, content of the file is obfuscated and moved to `.vncpass`.

The level of security provided by the VNC password depends on two things:

* The type of communication channel (encrypted/unencrypted).
* How secure access to the host is.

When using a VNC password, it is highly desirable to enable the secure
connection to prevent sending the password in clear over an unencrypted channel.

**ATTENTION**: Password is limited to 8 characters.  This limitation comes from
the Remote Framebuffer Protocol [RFC](https://tools.ietf.org/html/rfc6143) (see
section [7.2.2](https://tools.ietf.org/html/rfc6143#section-7.2.2)).  Any
characters beyhond the limit are ignored.

## Shell Access

To get shell access to a the running container, execute the following command:

```shell
docker exec -ti clrmamepro bash
```

## Support or Contact

Having troubles with the container or have questions?  Please [create a new issue](https://github.com/mikenye/docker-clrmamepro/issues).
