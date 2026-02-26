#!/bin/bash
set -e

DISPLAY_NAME="${DISPLAY_NAME:-${SERVER_NAME}}"

echo "=== Stationeers Dedicated Server ==="
echo "Server Name:  ${SERVER_NAME}"
echo "Display Name: ${DISPLAY_NAME}"
echo "World Type:   ${WORLD_TYPE}"
echo "Save Name:    ${SAVE_NAME}"
echo "Game Port:    ${GAME_PORT}"
echo "Update Port:  ${UPDATE_PORT}"

# Fix ownership on the bind-mounted saves directory
chown -R stationeers:stationeers "${SAVES_DIR}"

echo "=== Updating game server via SteamCMD ==="
gosu stationeers "${STEAMCMD_DIR}/steamcmd.sh" \
    +force_install_dir "${SERVER_DIR}" \
    +login anonymous \
    +app_update "${STEAMAPPID}" validate \
    +quit

echo "=== Starting dedicated server ==="
cd "${SERVER_DIR}"

SETTINGS_ARGS=(
    StartLocalHost true
    ServerVisible "${SERVER_VISIBLE}"
    GamePort "${GAME_PORT}"
    UpdatePort "${UPDATE_PORT}"
    UPNPEnabled false
    ServerName "${DISPLAY_NAME}"
    ServerMaxPlayers "${MAX_PLAYERS}"
    AutoSave "${AUTO_SAVE}"
    SaveInterval "${SAVE_INTERVAL}"
    AutoPauseServer "${AUTO_PAUSE}"
    UseSteamP2P false
    LocalIpAddress 0.0.0.0
)

if [ -n "${SERVER_PASSWORD}" ]; then
    SETTINGS_ARGS+=(ServerPassword "${SERVER_PASSWORD}")
fi

if [ -n "${SERVER_AUTH_SECRET}" ]; then
    SETTINGS_ARGS+=(ServerAuthSecret "${SERVER_AUTH_SECRET}")
fi

LOG_FILE="${SERVER_DIR}/server.log"
gosu stationeers touch "${LOG_FILE}"

SERVER_ARGS=(
    -file start "${SAVE_NAME}" "${WORLD_TYPE}" "${WORLD_DIFFICULTY}"
    -logFile "${LOG_FILE}"
    -settings "${SETTINGS_ARGS[@]}"
)

tail -F "${LOG_FILE}" &
exec gosu stationeers ./rocketstation_DedicatedServer.x86_64 "${SERVER_ARGS[@]}"
