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
2. Create a `.env` file using [`.env.example`](.env.example) as a reference.
3. Build the Plexflix companion docker images by running `make build`
4. Create the Rclone configuration files by running `make rclone-setup` and following the prompts.
5. Create a `.mountcheck` file on Google Drive. This file will tell the Plexflix companions your mount is healthy.

## Setup

When running the Plexflix companion for the first time, after doing a `make up`:

1. Configure NZBGet by visiting either `http://<YOUR_IP>:<NZBGET_PORT>`.
2. Configure Radarr by visiting either `http://<YOUR_IP>:<RADARR_PORT>`.
3. Configure Sonarr by visiting either `http://<YOUR_IP>:<SONARR_PORT>`.
4. Configure Tautulli by visiting either `http://<YOUR_IP>:<TAUTULLI_PORT>`.

## Usage

To bring up Plexflix companions:

```
make up
```

To bring down Plexflix companions:

```
make down
```

To restart a service:

```
make restart service="<service>"
```

To stop a service:

```
make stop service="<service>"
```

To view logs:

```
make logs [service="<service>"] [file=/path/to/log/file]
```

To (re)build one or more services

```
make build [service="<service>"]
```

To clean the Plexflix companion project (will require another `make build`):

```
make clean
```

## FAQ

If you get an error such as `..is mounted on /Users but it is not a shared mount...` run `make fuse-shared-mount dir=/Users` where `dir` is your root directory.
