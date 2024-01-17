FROM docker:24.0.7-dind-alpine3.19 as base
ARG TARGETPLATFORM

#RUN apt update && apt install --no-install-recommends --yes bash openssh-server execline git sudo rsync curl xz-utils wget
#RUN apk add bash openssh-server execline git sudo rsync curl wget coreutils openssh
RUN apk update && apk --no-cache upgrade && \
     apk add bash openssh-server execline git sudo rsync curl wget coreutils

ARG S6_OVERLAY_VERSION=3.1.6.2

ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp

RUN tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-symlinks-arch.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-symlinks-arch.tar.xz
RUN case ${TARGETPLATFORM} in \
         "linux/amd64")  ARCH=x86_64  ;; \
         "linux/arm64")  ARCH=aarch64  ;; \
         "linux/arm/v7") ARCH=aarch64  ;; \
         "linux/arm/v6") ARCH=aarch64  ;; \
         "linux/386")    ARCH=i386   ;; \
    esac \
    && wget --no-check-certificate https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${ARCH}.tar.xz -P /tmp \
    && tar -C / -Jxpf /tmp/s6-overlay-${ARCH}.tar.xz

ENTRYPOINT ["/init"]

##### Install gravity-sync
RUN curl -sSL https://raw.githubusercontent.com/vmstan/gs-install/main/gs-install.sh | GS_DOCKER=1 bash

# patch gravity-sync script to not auto-detect if type already specified
RUN /bin/sed -i -E 's/(function[[:space:]]*detect_local_pihole[[:space:]]*\{)/\1\n[ ! -z "$\{LOCAL_PIHOLE_TYPE\}" ] \&\& return\n/' /usr/local/bin/gravity-sync && \
    /bin/sed -i -E 's/(function[[:space:]]*detect_remote_pihole[[:space:]]*\{)/\1\n[ ! -z "$\{REMOTE_PIHOLE_TYPE\}" ] \&\& return\n/' /usr/local/bin/gravity-sync

# create an empty gravity-sync file so that all params are loaded from env vars
RUN touch /etc/gravity-sync/gravity-sync.conf

## create links to docker executable where gravity-script expecting to find them
RUN ln -s /usr/local/bin/docker /usr/local/bin/podman

# Use podman PiHole type as the logic in Gravity-Sync for podman or a docker-in-docker process are the same
ENV LOCAL_DOCKER_BINARY /usr/local/bin/docker
ENV LOCAL_PODMAN_BINARY /usr/local/bin/podman
ENV REMOTE_DOCKER_BINARY /usr/local/bin/docker
ENV REMOTE_PODMAN_BINARY /usr/local/bin/podman
ENV LOCAL_PIHOLE_TYPE "podman"
ENV REMOTE_PIHOLE_TYPE "podman"
ENV REMOTE_USER "gravitysync"
ENV LOCAL_USER "gravitysync"
ENV LOCAL_FILE_OWNER: "999:1000"
ENV REMOTE_FILE_OWNER: "999:1000"
ENV GS_ETC_PATH /config/gravity-sync

# Copy startup scripts and configurations
COPY src/etc /etc
COPY src/usr /usr

