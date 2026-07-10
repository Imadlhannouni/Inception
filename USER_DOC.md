# User Documentation

## Services provided

- **Nginx** — HTTPS web server / reverse proxy (entry point for the site)
- **WordPress** — the CMS powering the website
- **MariaDB** — database used by WordPress
- **Redis** — cache used by WordPress (bonus)
- **VSFTPD** — FTP server to manage WordPress files (bonus)
- **Adminer** — web UI to browse the database (bonus)
- **Portainer** — web UI to manage Docker containers (bonus)
- **Static website** — a simple extra website (bonus)

## Starting and stopping the project

```bash
make all     # build images and start every service
make stop    # stop all services, data is kept
make start   # start services again after "make stop"
make re      # rebuild and restart everything
make down    # remove containers/networks, data is kept
make fclean  # remove everything, including all data
```

## Accessing the website and the administration panel

- Website: https://localhost/ (self-signed certificate, the browser will warn about it)
- WordPress admin panel: https://localhost/wp-admin/
- Database admin (Adminer): http://localhost:8080/
- Container admin (Portainer): https://localhost:9443/
- Bonus static website: http://localhost:8081/

## Locating and managing credentials

All credentials are defined in `srcs/.env`:

- `WP_ADMIN_USER` / `WP_ADMIN_PASSWORD` — WordPress admin account
- `WP_USER` / `WP_USER_PASSWORD` — regular WordPress account
- `SQL_USER` / `SQL_PASSWORD` — WordPress database user
- `SQL_ROOT_PASSWORD` — database root password

This file is not versioned in git; it should be created/edited manually and kept private.

## Checking that services are running correctly

```bash
docker ps
```

All containers (nginx, wordpress, mariadb, redis, vsftpd, adminer, portainer, static_website) should appear with status "Up".

To check a specific service:

```bash
docker logs <container_name>
```

You can also simply open https://localhost/ in a browser to check the website, or http://localhost:8080/ to check that Adminer can connect to the database.
