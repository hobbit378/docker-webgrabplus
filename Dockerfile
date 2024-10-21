# syntax=docker/dockerfile:1
ARG BASEIMG=ghcr.io/linuxserver/baseimage-alpine:3.20
FROM ${BASEIMG}

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="saarg"

# package versions
ARG WEBGRAB_VER

# environment variables.
ENV HOME /config

RUN \
  echo "**** install packages ****" && \
  apk -U --update --no-cache add \
    icu-libs \
    iputils \
    unzip && \
  echo "**** install dotnet sdk ****" && \
  mkdir -p /app/dotnet && \
  curl -o /tmp/dotnet-install.sh -L \
    https://dot.net/v1/dotnet-install.sh && \
  chmod +x /tmp/dotnet-install.sh && \
  /tmp/dotnet-install.sh -c 8.0 --install-dir /app/dotnet --runtime dotnet && \
  echo "**** install webgrabplus ****" && \
  if [ -z "$WEBGRAB_VER" ]; then \
    WEBGRAB_VER=$(curl -fsL http://webgrabplus.com/download/sw | grep -m1 /download/sw/v | sed 's|.*/download/sw/v\(.*\)">V.*|\1|'); \
  fi && \
  echo "Found Webgrabplus version ${WEBGRAB_VER}" && \
  WEBGRAB_URL=$(curl -fsL http://webgrabplus.com/download/sw/v${WEBGRAB_VER} | grep '>Linux</a>' | sed 's|.*\(http://webgrab.*.gz\).*|\1|') && \
  mkdir -p \
    /app/wg++ && \
  curl -o /tmp/wg++.tar.gz -L \
    "${WEBGRAB_URL}" && \
  tar xzf \
    /tmp/wg++.tar.gz -C \
    /app/wg++ --strip-components=1 && \
  echo "**** download siteini.pack ****" && \
  curl -o \
    /tmp/ini.zip -L \
    http://www.webgrabplus.com/sites/default/files/download/ini/SiteIniPack_current.zip && \
  unzip -q /tmp/ini.zip -d /defaults/ini/ && \
  printf "Linuxserver.io version: ${VERSION}\nBuild-date: ${BUILD_DATE}" > /build_version && \
  echo "**** link init script ****" && \
  ln -s /etc/s6-overlay/s6-rc.d/init-webgrabplus-config/run /bin/init-webgrab && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/*

# copy files
COPY root/ /

# clear ENTRYPOINT of base image in order to prevent s6 upstart;
# in case the container should be permanently running, (re-)define --entrypoint ["/init"] at the commandline
ENTRYPOINT []

# change standard command to init container und update EPG and then exit
# if necessary override the command when creating/running the container with sleep x and than enter conter with docker exec ... /bin/bash
CMD  /bin/bash -c "source /bin/init-webgrab; source /app/update.sh"

# ports and volumes
VOLUME /config /data
