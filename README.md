*This project has been created as part of the 42 curriculum by ilhannou.*

# Inception

## Description

Inception is a Docker infrastructure project that sets up a small web hosting stack using Docker Compose. The goal is to learn container orchestration by building each service from a Debian base image and making them work together: a reverse proxy, a CMS, a database, and a few bonus services (cache, FTP, DB admin UI, container UI, static website).

## Instructions

```bash
# Build and start all services
make all

# Stop services (data is kept)
make stop

# Start previously stopped services
make start

# Rebuild and restart everything
make re

# Remove containers and networks (data is kept)
make down

# Remove everything, including data
make fclean
```

Credentials and configuration are defined in `srcs/.env` (not versioned).

- Website: https://localhost/
- WordPress admin: https://localhost/wp-admin/
- Adminer: http://localhost:8080/
- Portainer: https://localhost:9443/
- Static website: http://localhost:8081/
- FTP: localhost:21

See [USER_DOC.md](USER_DOC.md) for usage details and [DEV_DOC.md](DEV_DOC.md) for setup/development details.

## Resources

- [Docker documentation](https://docs.docker.com/)
- [Docker Compose file reference](https://docs.docker.com/compose/compose-file/)
- [Nginx documentation](https://nginx.org/en/docs/)
- [WordPress developer resources](https://developer.wordpress.org/)
- [MariaDB documentation](https://mariadb.com/docs/)
- [Redis documentation](https://redis.io/documentation)

**AI usage**: AI was used to help draft and structure this documentation (README, USER_DOC, DEV_DOC) and to review Docker Compose/Dockerfile configurations for common mistakes. All Dockerfiles, service configuration, and orchestration logic were written and tested manually.

## Project Description

The project runs one Docker container per service (Nginx, WordPress+PHP-FPM, MariaDB, and bonus services: Redis, VSFTPD, Adminer, Portainer, static website), each built from its own Dockerfile based on a Debian image, and orchestrated with `docker-compose.yml`. Services are split across two bridge networks (front-facing and back-end), and persistent data is kept outside the containers.

### Virtual Machines vs Docker

Docker containers share the host kernel instead of virtualizing an entire OS, so they start in seconds, use far less disk/RAM than a VM, and stay lightweight even with several services running at once. A VM would give stronger isolation but at the cost of much more overhead, which isn't needed for isolating simple services like these on a single host.

### Secrets vs Environment Variables

This project uses an `.env` file (kept out of git) for configuration such as domain name, database credentials, and WordPress admin/user credentials. Environment variables are simple and standard for Docker Compose, but they are visible via `docker inspect`. Docker secrets, mounted as files inside the container, are safer since only the processes that need them can read them. Here, environment variables were chosen for simplicity, with sensitive values never hardcoded and the `.env` file excluded from version control.

### Docker Network vs Host Network

The stack uses custom bridge networks (`front` and `back`) instead of the host network. This isolates services from each other and from the host: only Nginx is exposed, WordPress/MariaDB/Redis/etc. only talk to each other through the internal network, and containers can resolve each other by name via Docker's DNS. The host network would expose all container ports directly on the host and remove this isolation, with a higher risk of port conflicts.

### Docker Volumes vs Bind Mounts

WordPress files and the MariaDB database are stored using bind mounts to a directory on the host (`~/data/`), so the data is easy to inspect, back up, and persists across container rebuilds. Named volumes (used for Portainer's data) are managed entirely by Docker and offer slightly better performance/portability, but are less convenient to access directly from the host. Bind mounts were preferred for WordPress/MariaDB so their data stays visible and easy to manage on the host filesystem.
