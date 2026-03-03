# Stationeers Dedicated Server (Docker)

Dockerized [Stationeers](https://store.steampowered.com/app/544550/Stationeers/) dedicated server. The game server is installed and updated automatically via SteamCMD on each container start.

## Quick Start

```bash
cp .env.example .env
# Edit .env to taste, then:
docker compose up -d
```

## Running Multiple Instances

Each server instance uses its own `.env` file with unique ports. Pass the file with `--env-file`:

```bash
docker compose --env-file .env.moon up -d
```

The `SERVER_NAME` value in each env file determines the container name (`stationeers-<SERVER_NAME>`) and the local save directory (`./data/<SERVER_NAME>/`). Make sure every instance has unique `GAME_PORT` and `UPDATE_PORT` values.

## Configuration

All settings are controlled via environment variables. Copy `.env.example` and adjust as needed.

| Variable | Default | Description |
|---|---|---|
| `TZ` | `UTC` | Container timezone |
| `SERVER_NAME` | `default` | Internal name; used for the container name and data directory |
| `DISPLAY_NAME` | value of `SERVER_NAME` | Name shown in the in-game server browser |
| `GAME_PORT` | `27016` | Game traffic port (UDP) |
| `UPDATE_PORT` | `27015` | Steam query port (UDP) |
| `WORLD_TYPE` | `Mars2` | World type (`Mars2`, `Lunar`, `Europa3`, `MimasHerschel`, `Vulcan`, `Venus`) |
| `WORLD_DIFFICULTY` | `Normal` | Difficulty setting |
| `SAVE_NAME` | `default` | Save file name inside the saves directory |
| `SERVER_VISIBLE` | `true` | List in the public server browser |
| `SERVER_PASSWORD` | *(empty)* | Password required to join |
| `SERVER_AUTH_SECRET` | *(empty)* | Auth secret for server administration |
| `MAX_PLAYERS` | `10` | Maximum concurrent players |
| `AUTO_SAVE` | `true` | Enable automatic saving |
| `SAVE_INTERVAL` | `300` | Seconds between auto-saves |
| `AUTO_PAUSE` | `true` | Pause the server when no players are connected |

## Volumes

| Mount | Purpose |
|---|---|
| `server-files` (named volume) | Game server installation managed by SteamCMD |
| `./data/<SERVER_NAME>/` (bind mount) | World save data, persisted on the host |

## Ports

Both ports are **UDP**. Forward them in your firewall/router for the server to be reachable.

| Port | Default | Purpose |
|---|---|---|
| Game port | `27016/udp` | Game client connections |
| Update port | `27015/udp` | Steam server-list queries |

## Rebuilding

After changing the `Dockerfile` or `entrypoint.sh`:

```bash
docker compose build
docker compose up -d
```

The game server binaries themselves update automatically on every container start via SteamCMD, so a rebuild is only needed for infrastructure changes.

## Build Arguments

| Argument | Default | Description |
|---|---|---|
| `PUID` | `1000` | UID for the `stationeers` user inside the container |
| `PGID` | `1000` | GID for the `stationeers` group inside the container |

Override at build time:

```bash
docker compose build --build-arg PUID=1001 --build-arg PGID=1001
```

## Logs

The entrypoint tails the game server log to stdout, so standard Docker log commands work:

```bash
docker compose logs -f
```
