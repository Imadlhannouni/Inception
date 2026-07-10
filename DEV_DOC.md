# Developer Documentation

## Setting up the environment from scratch

### Prerequisites

- A Linux VM/host with Docker Engine and Docker Compose installed
- `make`

### Configuration files / secrets

Create `srcs/.env` with the following variables (this file is not versioned):

```env
DOMAIN_NAME=your_login.42.fr

SQL_DATABASE=wordpress
SQL_USER=wordpress_user
SQL_PASSWORD=change_me
SQL_ROOT_PASSWORD=change_me
SQL_HOST=mariadb

WP_TITLE=Inception
WP_ADMIN_USER=admin_username
WP_ADMIN_PASSWORD=change_me
WP_ADMIN_EMAIL=admin@example.com
WP_USER=regular_user
WP_USER_PASSWORD=change_me
WP_USER_EMAIL=user@example.com
```

## Building and launching with Makefile / Docker Compose

```bash
make all      # equivalent to: make setup + docker compose up --build -d
make setup    # create data directories in ~/data/
make build    # build images without starting them
make start    # start containers
make stop     # stop containers, keep data
make re       # stop, rebuild and restart
make down     # remove containers/networks, keep data
make fclean   # remove containers, networks and all data
```

Equivalent raw Docker Compose commands:

```bash
docker compose -f srcs/docker-compose.yml build
docker compose -f srcs/docker-compose.yml up -d
docker compose -f srcs/docker-compose.yml logs -f
docker compose -f srcs/docker-compose.yml down
```

## Managing containers and volumes

```bash
docker ps -a                          # list containers
docker logs -f <container_name>       # follow logs of a service
docker exec -it <container_name> bash # open a shell in a container
docker compose -f srcs/docker-compose.yml up -d --build <service> # rebuild one service

docker volume ls                      # list volumes
docker volume inspect <volume_name>   # inspect a volume
```

## Where project data is stored and how it persists

- WordPress files (bind mount): `~/data/wordpress` → `/var/www/wordpress` in the container
- MariaDB files (bind mount): `~/data/mariadb` → `/var/lib/mysql` in the container
- Portainer data (named volume): managed by Docker directly

Because WordPress and MariaDB use bind mounts on the host, their data survives `make down` and container rebuilds. It is only removed by `make fclean`, which deletes the `~/data/` directory content and Docker volumes.
