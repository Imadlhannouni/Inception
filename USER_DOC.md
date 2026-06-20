# User Documentation

## Overview

The Inception project is a containerized web infrastructure stack running multiple services using Docker Compose. This documentation explains how to operate and manage the services without needing technical knowledge of the underlying implementation.

## Services Provided

The stack includes the following services:

- **WordPress**: A content management system (CMS) for website management
- **Nginx**: A web server and reverse proxy handling HTTPS traffic on port 443
- **MariaDB**: A relational database storing WordPress data
- **Redis**: An in-memory cache for performance optimization
- **VSFTPD**: FTP server for file transfers to the WordPress directory
- **Adminer**: A database management web interface (port 8080)
- **Static Website**: A bonus service accessible on port 8081
- **Portainer**: A Docker container management interface (port 9443)

## Quick Start

### Starting the Stack

To build and start all services:

```bash
make all
```

This command will:
1. Create necessary data directories
2. Build Docker images
3. Start all containers in the background

### Stopping the Stack

To stop all running services without removing data:

```bash
make stop
```

### Starting Stopped Services

To restart services after stopping:

```bash
make start
```

### Restarting the Stack

To perform a clean restart (removes and rebuilds everything, preserving data):

```bash
make re
```

### Removing Everything

To remove all containers, networks, and images (keeping data):

```bash
make down
```

To completely remove all data including volumes:

```bash
make fclean
```

## Accessing Services

### Main Website
- **URL**: https://localhost/
- **Service**: WordPress (secured with HTTPS)
- **Note**: Browser may show a security warning due to self-signed certificate

### Administration Panels

#### WordPress Admin Panel
- **URL**: https://localhost/wp-admin/
- **Credentials**: Configured in `srcs/.env`

#### Database Management (Adminer)
- **URL**: http://localhost:8080/
- **Credentials**: Database credentials in `srcs/.env`

#### Static Bonus Website
- **URL**: http://localhost:8081/
- **Description**: A static HTML website for testing

#### Container Management (Portainer)
- **URL**: https://localhost:9443/
- **Description**: Web interface for managing Docker containers and images

### File Transfer (FTP)
- **Server**: localhost
- **Port**: 21 (standard FTP)
- **Credentials**: Configured in `srcs/.env`
- **Directory**: `/var/www/wordpress`

## Credentials Configuration

All credentials are stored in the `srcs/.env` file:

- `WP_ADMIN_USER` and `WP_ADMIN_PASSWORD` - WordPress admin account
- `SQL_PASSWORD` - Database user password
- `SQL_ROOT_PASSWORD` - Database root password

**Important**: Never commit the `.env` file to version control. It contains sensitive information.

## Checking Service Status

### View Running Containers

```bash
docker ps
```

This shows all active containers and their status. Look for these containers:
- `nginx` - Web server (should be running)
- `wordpress` - CMS application
- `mariadb` - Database
- `redis` - Cache service
- `vsftpd` - FTP server
- `adminer` - Database UI
- `portainer` - Container manager
- `static_website` - Static content

### View Container Logs

To check if a service is running correctly, view its logs:

```bash
docker logs <container_name>
```

Example:
```bash
docker logs wordpress
docker logs nginx
docker logs mariadb
```

### Check Data Directory

Data is stored in your home directory:

```bash
ls -la ~/data/
```

You should see:
- `~/data/wordpress/` - WordPress files and uploads
- `~/data/mariadb/` - Database files

## Verifying Services Are Running Correctly

### WordPress
1. Visit https://localhost/
2. You should see the WordPress homepage
3. Check the admin panel at https://localhost/wp-admin/

### Database (MariaDB)
1. Visit http://localhost:8080/ (Adminer)
2. Log in with database credentials from `srcs/.env` (SQL_USER, SQL_PASSWORD)
3. You should see WordPress database tables

### FTP Server
```bash
ftp localhost
# Use credentials from srcs/.env
```

### Redis Cache
Check via Portainer or view logs:
```bash
docker logs redis
```

## Troubleshooting

### Services Won't Start
1. Check available disk space: `df -h`
2. Ensure Docker is running: `docker ps`
3. View container logs for errors: `docker logs <service_name>`
4. Check port availability (443, 8080, 8081, 9000, 9443 must be free)

### Can't Access Website
1. Verify nginx is running: `docker ps | grep nginx`
2. Check logs: `docker logs nginx`
3. Ensure port 443 is not blocked by firewall
4. Try accessing from a different browser or incognito mode (certificate cache)

### Database Connection Issues
1. Verify MariaDB is running: `docker ps | grep mariadb`
2. Check database logs: `docker logs mariadb`
3. Verify credentials in `srcs/.env`
4. Ensure data directory exists: `ls -la ~/data/mariadb/`

### FTP Connection Problems
1. Check VSFTPD is running: `docker ps | grep vsftpd`
2. Verify credentials in `srcs/.env`
3. Ensure port 21 is accessible
4. Check logs: `docker logs vsftpd`

## Data Persistence

All application data is stored in Docker volumes bound to your home directory:

- **WordPress Files**: `~/data/wordpress/` - Contains WordPress installation and uploads
- **Database Files**: `~/data/mariadb/` - Contains all database data

This ensures your data persists even if containers are removed or rebuilt. To preserve your data:
- Use `make down` instead of `make fclean` when you want to keep data
- Regularly backup the `~/data/` directory
- Never use `make fclean` unless you want to delete all data

## Support

For technical details, refer to DEV_DOC.md.
