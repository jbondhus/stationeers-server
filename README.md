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
| `SERVER_VISIBLE` | `false` | List in the public server browser (off: the server is tailnet-only) |
| `SERVER_PASSWORD` | *(empty)* | Password required to join |
| `SERVER_AUTH_SECRET` | *(empty)* | Auth secret for server administration |
| `MAX_PLAYERS` | `10` | Maximum concurrent players |
| `AUTO_SAVE` | `true` | Enable automatic saving |
| `SAVE_INTERVAL` | `300` | Seconds between auto-saves |
| `AUTO_PAUSE` | `true` | Pause the server when no players are connected |
| `TS_AUTHKEY` | *(empty)* | One-off tagged Tailscale auth key for the world's node (first start only) |
| `TS_TAG` | `tag:house-game` | Tag the node advertises; the tailnet policy keys on it |
| `MEM_LIMIT` | `8g` | Memory limit of the game container |

## Volumes

| Mount | Purpose |
|---|---|
| `server-files` (named volume) | Game server installation managed by SteamCMD |
| `stationeers-<SERVER_NAME>-ts` (named volume) | The world's Tailscale node identity |
| `./data/<SERVER_NAME>/` (bind mount) | World save data, persisted on the host |

## Networking: one Tailscale node per world

Each world's compose project includes a `tailscale` sidecar, and the game server runs in the sidecar's network namespace. The
world is reachable at its node's tailnet address on `GAME_PORT`; nothing is published on the host and no port forwarding exists.
This is what makes the server usable from a home connection behind CGNAT.

- The node is named `stationeers-<SERVER_NAME>` and carries the tag in `TS_TAG`; the tailnet policy grants the game ports to
  the people who may play (shared-in users and admins) and nothing else. The node has no SSH and no source role.
- First start: create a one-off, tagged, non-reusable auth key in the admin console and put it in the env file as `TS_AUTHKEY`.
  The key is used once; the node's identity then lives in the `stationeers-<SERVER_NAME>-ts` volume.
- Friends: share the world's node with them from the admin console (Machines → the node → Share). They install Tailscale,
  accept the share, and join in-game by direct connect with the node's address and `GAME_PORT`. The in-game server browser does
  not list it (`SERVER_VISIBLE=false`).
- The sidecar needs `NET_ADMIN` and `/dev/net/tun`; both work under Docker's user-namespace remap (verified 2026-10-29).

## Ports

Both ports are **UDP**, open on the world's tailnet node.

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
