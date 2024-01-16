FROM docker:24.0.7-dind-alpine3.19
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

COPY src/etc /etc
COPY src/usr/local/bin/_gs_cron /usr/local/bin
COPY gravity-sync /usr/local/bin