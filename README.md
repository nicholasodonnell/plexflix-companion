<img src="logo/logo.png" />

Collection of dockerized companion services for [nicholasodonnell/plexflix](https://github.com/nicholasodonnell/plexflix).

### Requirements

- [Docker Community Edition](https://www.docker.com/community-edition)
- [Docker Compose](https://docs.docker.com/compose/)
- [GNU make](https://www.gnu.org/software/make/)
- [Google Drive](https://drive.google.com/)

### Services

- **NZBGet** - Usenet download client.
- **Radarr** - Searches, downloads, and manages movies.
- **Rclone** - Mounts a write-enabled, Google Drive account as a fuse filesystem.
- **Sonarr** - Searches, downloads, and manages TV shows.
- **Tautulli** - Monitoring and tracking tool for Plex.

## Installation

1. Install fuse on your system (optional).
2. Create a `.env` file using [`.env.example`](.env.example) as a reference:
  `cp -n .env{.example,}`.
3. Create a `docker-compose.override.yml` file using [`docker-compose.override.example.yml`](docker-compose.override.example.yml) as a reference:
  `cp -n docker-compose.override{.example,}.yml`.
4. Build the Plexflix companion docker images by running `make build`
5. Create the Rclone configuration files by running `make rclone-setup` and following the prompts.
6. Create a `.mountcheck` file on Google Drive. This file will tell the Plexflix companions your mount is healthy.

## Setup

When running the Plexflix companion for the first time, after doing a `make up`:

1. Configure NZBGet by visiting either `http://<YOUR_IP>:<NZBGET_PORT>`.
2. Configure Radarr by visiting either `http://<YOUR_IP>:<RADARR_PORT>`.
3. Configure Sonarr by visiting either `http://<YOUR_IP>:<SONARR_PORT>`.
4. Configure Tautulli by visiting either `http://<YOUR_IP>:<TAUTULLI_PORT>`.

## Usage

To start the collection:

```
make up
```

To stop the collection:

```
make down
```

To view logs:

```
make logs [service="<service>"] [file="/path/to/log/file"]
```

To build docker images:

```
make build
```

To remove docker images:

```
make clean
```

To see the health of the Rclone mount:

```
make mount-health
```

## ENV Options

| Option                 | Description                                                                                                                              |
| ---------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| `USER`                 | `PUID` of user for volume mounts. Ensures any volume directories on the host are owned by the same user to avoid any permissions issues. |
| `GROUP`                | `PGID` of user for volume mounts. Ensures any volume directories on the host are owned by the same user to avoid any permissions issues. |
| `TIMEZONE`             | Timezone to use.                                                                                                                         |
| `LIBRARIES_MOUNT_PATH` | Path on the host to mount Google Drive libraries.                                                                                        |
| `DOWNLOADS_PATH`       | Path on the host to mount downloads.                                                                                                     |
| `NZBGET_PORT`          | Host port for NZBGet.                                                                                                                    |
| `NZBGET_CONFIG_PATH`   | Host location for NZBGet configuration files.                                                                                            |
| `RADARR_PORT`          | Host port for Radarr.                                                                                                                    |
| `RADARR_CONFIG_PATH`   | Host location for Radarr configuration files.                                                                                            |
| `RCLONE_CONFIG_PATH`   | Host location for Rclone configuration files.                                                                                            |
| `RCLONE_MOUNT_OPTIONS` | Rclone mount options. See https://rclone.org/commands/rclone_mount for more information.                                                 |
| `RCLONE_REMOTE_MOUNT`  | Name of your Rclone mount defined during setup.                                                                                          |
| `SONARR_PORT`          | Host port for Sonarrr.                                                                                                                   |
| `SONARR_CONFIG_PATH`   | Host location for Sonarr configuration files.                                                                                            |
| `TAUTULLI_PORT`        | Host port for Tautulli.                                                                                                                  |
| `TAUTULLI_CONFIG_PATH` | Host location for Tautulli configuration files.                                                                                          |

## FAQ

If you get an error such as `..is mounted on /Users but it is not a shared mount...` run `make fuse-shared-mount dir=/Users` where `dir` is your root directory.

If you get an error such as `...mount: /host_mnt/dir: not mount point or bad option...` turn off `Use gRPC FUSE for file sharing` in your Docker preferences.
