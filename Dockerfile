FROM debian:trixie-slim

ARG PUID=1000
ARG PGID=1000

ENV STEAMAPPID=600760
ENV SERVER_DIR=/home/stationeers/server
ENV SAVES_DIR=/home/stationeers/server/saves
ENV STEAMCMD_DIR=/opt/steamcmd

ENV SERVER_NAME="Stationeers Server"
ENV DISPLAY_NAME=""
ENV SERVER_PASSWORD=""
ENV SERVER_AUTH_SECRET=""
ENV SAVE_NAME="default"
ENV WORLD_TYPE="Mars2"
ENV WORLD_DIFFICULTY="Normal"
ENV GAME_PORT=27016
ENV UPDATE_PORT=27015
ENV MAX_PLAYERS=10
ENV AUTO_SAVE=true
ENV SAVE_INTERVAL=300
ENV SERVER_VISIBLE=true
ENV AUTO_PAUSE=true

ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

RUN dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        lib32gcc-s1 \
        lib32stdc++6 \
        ca-certificates \
        curl \
        gosu \
        locales \
    && rm -rf /var/lib/apt/lists/* \
    && sed -i 's/^# *en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen \
    && locale-gen

RUN mkdir -p "${STEAMCMD_DIR}" \
    && curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" \
       | tar -xzC "${STEAMCMD_DIR}"

RUN groupadd -g "${PGID}" stationeers \
    && useradd -m -u "${PUID}" -g "${PGID}" -s /bin/bash stationeers \
    && mkdir -p "${SERVER_DIR}" "${SAVES_DIR}" \
    && chown -R stationeers:stationeers "${SERVER_DIR}" "${STEAMCMD_DIR}"

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE ${GAME_PORT}/udp
EXPOSE ${UPDATE_PORT}/udp

ENTRYPOINT ["/entrypoint.sh"]
