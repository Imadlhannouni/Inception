# Developer Documentation

## Project Overview

Inception is a containerized web infrastructure project using Docker Compose. It orchestrates multiple services (Nginx, WordPress, MariaDB, Redis, FTP, Adminer, Portainer, and a static website) to create a complete web hosting environment.

## Prerequisites

### System Requirements
- Linux operating system (Debian/Ubuntu recommended)
- 4GB RAM minimum
- 10GB free disk space
- Ports available: 443, 21, 8080, 8081, 9000, 9443

### Required Software
- Docker Engine (version 20.10+)
- Docker Compose (version 2.0+)
- Make
- Bash shell

### Installation

```bash
# Docker (Ubuntu/Debian)
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Docker Compose
sudo apt-get install docker-compose

# Make
sudo apt-get install build-essential
```

## Project Structure

```
Inception/
├── Makefile                    # Build automation
├── README.md                   # Project overview
├── DEV_DOC.md                  # This file
├── USER_DOC.md                 # User guide
└── srcs/
    ├── docker-compose.yml      # Service orchestration
    ├── .env                    # Environment variables
    └── requirements/
        ├── mariadb/            # Database service
        │   ├── Dockerfile
        │   ├── conf/
        │   └── tools/
        ├── nginx/              # Web server
        │   ├── Dockerfile
        │   └── conf/
        ├── wordpress/          # CMS application
        │   ├── Dockerfile
        │   ├── conf/
        │   └── tools/
        └── bonus/              # Optional services
            ├── redis/
            ├── ftp/
            ├── website/
            ├── adminer/
            └── portainer/
```

## Environment Setup

### Configuration Files

Create a `.env` file in `srcs/` with required variables:

```bash
# Domain Configuration
DOMAIN_NAME=your_login.42.fr

# Database Configuration
SQL_DATABASE=wordpress
SQL_USER=wordpress_user
SQL_PASSWORD=secure_password_here
SQL_ROOT_PASSWORD=secure_root_password_here
SQL_HOST=mariadb

# WordPress Configuration
WP_TITLE=Inception
WP_ADMIN_USER=admin_username
WP_ADMIN_PASSWORD=secure_admin_password
WP_ADMIN_EMAIL=admin@example.com

WP_USER=regular_user
WP_USER_PASSWORD=user_password
WP_USER_EMAIL=user@example.com
```

## Building and Launching

### Full Build and Start

```bash
make all
```

This executes:
1. `make setup` - Creates data directories at `~/data/mariadb` and `~/data/wordpress`
2. Builds all Docker images
3. Starts all containers in detached mode with `docker compose up --build -d`

### Individual Commands

```bash
# Setup data directories only
make setup

# Build containers (without starting)
make build

# Start containers
make start

# Stop containers (preserve data)
make stop

# Restart containers
make re

# Remove containers and networks
make down

# Deep clean (removes all including data)
make fclean
```

### Docker Compose Commands

Direct Docker Compose commands:

```bash
# Build images
docker compose -f srcs/docker-compose.yml build

# Start services
docker compose -f srcs/docker-compose.yml up -d

# View logs
docker compose -f srcs/docker-compose.yml logs -f

# Execute command in container
docker compose -f srcs/docker-compose.yml exec <service> <command>

# Rebuild specific service
docker compose -f srcs/docker-compose.yml up -d --build <service>
```

## Container Management

### Viewing Containers

```bash
# List running containers
docker ps

# List all containers (including stopped)
docker ps -a

# View container logs
docker logs <container_name>
docker logs -f <container_name>        # Follow logs in real-time

# View container resource usage
docker stats

# Inspect container details
docker inspect <container_name>
```

### Executing Commands

```bash
# Execute command in running container
docker exec -it <container_name> <command>

# Interactive bash shell
docker exec -it <container_name> bash

# Example commands
docker exec -it mariadb mysql -u root -p   # MySQL CLI
docker exec -it wordpress wp cli command    # WordPress CLI
docker exec -it nginx nginx -t              # Test nginx config
```

### Restarting Services

```bash
# Restart single service
docker restart <container_name>

# Restart from compose file
docker compose -f srcs/docker-compose.yml restart <service>

# Rebuild and restart
docker compose -f srcs/docker-compose.yml up -d --build <service>
```

## Volume and Data Management

### Volume Types Used

#### Bind Mounts (WordPress and MariaDB)
```yaml
volumes:
  - ~/data/wordpress:/var/www/wordpress
  - ~/data/mariadb:/var/lib/mysql
```

**Advantages**:
- Direct host filesystem access
- Easy backup and migration
- Visible from host machine
- Better for development

**Disadvantages**:
- Slower performance (especially on non-Linux)
- Permission issues possible
- Not portable across hosts

#### Named Volumes (Portainer)
```yaml
volumes:
  - portainer_data:/var/lib/portainer
```

**Advantages**:
- Better performance
- Docker manages the location
- Easier volume operations

**Disadvantages**:
- Less visible from host
- Harder to backup

### Data Locations

```bash
# WordPress data
~/data/wordpress/
  ├── wp-content/          # Themes, plugins, uploads
  ├── wp-config.php        # Configuration
  └── [WordPress files]

# MariaDB data
~/data/mariadb/
  ├── wordpress_db/        # Database files
  ├── ibdata1              # Shared tablespace
  └── [System databases]
```

### Volume Operations

```bash
# List all volumes
docker volume ls

# Inspect volume
docker volume inspect <volume_name>

# Remove unused volumes
docker volume prune

# Backup volume data
docker run --rm -v <volume>:/data -v $(pwd):/backup alpine \
  tar czf /backup/volume.tar.gz -C /data .

# Restore volume from backup
docker run --rm -v <volume>:/data -v $(pwd):/backup alpine \
  tar xzf /backup/volume.tar.gz -C /data
```

## Service-Specific Details

### Nginx (Port 443)
- **Purpose**: Web server and HTTPS reverse proxy
- **Config**: `srcs/requirements/nginx/conf/inception.conf`
- **SSL**: Self-signed certificate (auto-generated)
- **Upstream**: Forwards traffic to WordPress container

### WordPress (Internal)
- **Purpose**: CMS application
- **Config**: `srcs/requirements/wordpress/conf/www.conf` (PHP-FPM)
- **Data**: `/var/www/wordpress`
- **Dependencies**: Requires MariaDB, Redis

### MariaDB (Internal)
- **Purpose**: Relational database
- **Config**: `srcs/requirements/mariadb/conf/mariadb.conf`
- **Data**: `/var/lib/mysql`
- **Initialization**: `srcs/requirements/mariadb/tools/maria.sh`

### Redis (Internal)
- **Purpose**: In-memory cache
- **Default Port**: 6379
- **Networks**: Backend only

### VSFTPD (Port 21)
- **Purpose**: FTP server for file uploads
- **Config**: `srcs/requirements/ftp/conf/vsftpd.conf`
- **Mount**: `/var/www/wordpress`

### Adminer (Port 8080)
- **Purpose**: Web database management
- **Supported**: MySQL/MariaDB, PostgreSQL, MongoDB, etc.
- **Access**: http://localhost:8080/

### Static Website (Port 8081)
- **Purpose**: Bonus service for testing
- **Content**: `srcs/requirements/bonus/website/site/`
- **Access**: http://localhost:8081/

### Portainer (Port 9443)
- **Purpose**: Docker UI management
- **Access**: https://localhost:9443/
- **Features**: Container, image, volume, and network management

## Networking Architecture

### Networks

```
Front Network (Bridge)
  - nginx
  - wordpress

Back Network (Bridge)
  - wordpress
  - mariadb
  - redis
  - vsftpd
  - adminer
```

### Communication

- **Nginx → WordPress**: Via Front and Back networks
- **WordPress → MariaDB**: Via Back network
- **WordPress → Redis**: Via Back network
- **Adminer → MariaDB**: Via Back network

## Configuration Files

### docker-compose.yml

Key sections:
- **services**: Defines all containers
- **volumes**: Declares volume mount points
- **networks**: Defines network bridges
- **env_file**: Points to `.env` for variables
- **restart policy**: `unless-stopped` ensures auto-restart

### Service Dockerfiles

Each service has a Dockerfile:
- **Base image**: Debian (lightweight)
- **Installed packages**: Minimal dependencies
- **Entrypoint/CMD**: Service startup command
- **Health checks**: Optional monitoring

## Troubleshooting

### Container Won't Start

```bash
# Check logs
docker logs <container_name>

# Inspect container
docker inspect <container_name>

# Check resource constraints
docker stats

# Rebuild from scratch
docker compose -f srcs/docker-compose.yml up -d --build <service>
```

### Port Already in Use

```bash
# Find process using port
lsof -i :<port_number>
sudo netstat -tlnp | grep :<port_number>

# Either stop the process or change port in docker-compose.yml
```

### Network Issues

```bash
# Check network connectivity
docker network ls
docker network inspect <network_name>

# Test DNS resolution inside container
docker exec <container> ping <other_container>

# Check network routes
docker exec <container> route -n
```

### Volume Permission Errors

```bash
# Check volume owner
ls -la ~/data/

# Fix permissions
sudo chown -R $USER:$USER ~/data/

# Or rebuild with correct permissions
docker compose -f srcs/docker-compose.yml down -v
make setup
docker compose -f srcs/docker-compose.yml up -d --build
```

### Database Connection Issues

```bash
# Test MariaDB connectivity
docker exec -it wordpress mysql -h mariadb -u wordpress_user -p wordpress_db

# Check MariaDB logs
docker logs mariadb

# Verify environment variables
docker exec wordpress env | grep DB_
```

## Development Workflow

### Modifying Services

1. Edit Dockerfile or configuration files
2. Rebuild the service:
   ```bash
   docker compose -f srcs/docker-compose.yml up -d --build <service>
   ```
3. Verify changes:
   ```bash
   docker logs <service>
   docker exec -it <service> bash
   ```

### Adding New Services

1. Create service directory: `srcs/requirements/<service>/`
2. Create Dockerfile
3. Add service definition to `docker-compose.yml`
4. Run: `docker compose -f srcs/docker-compose.yml up -d --build`

### Testing Configuration

```bash
# Validate docker-compose.yml
docker compose -f srcs/docker-compose.yml config

# Build images without starting
docker compose -f srcs/docker-compose.yml build

# Start with verbose logging
docker compose -f srcs/docker-compose.yml up
```

## Performance Optimization

### Cache Configuration

Redis is configured for WordPress caching through plugins like Redis Object Cache.

### Database Optimization

MariaDB configuration in `srcs/requirements/mariadb/conf/mariadb.conf` includes tuning for performance.

## Monitoring and Logging

```bash
# Real-time logs
docker compose -f srcs/docker-compose.yml logs -f

# Specific service logs
docker logs -f <container_name>

# Last 100 lines
docker logs --tail 100 <container_name>

# Logs since specific time
docker logs --since 10m <container_name>
```

## Cleanup and Maintenance

### Regular Maintenance

```bash
# Remove unused images
docker image prune -a

# Remove unused volumes
docker volume prune

# Remove unused networks
docker network prune

# Remove all stopped containers
docker container prune
```

### Full Reset

```bash
# Option 1: Keep data
make clean
make all

# Option 2: Remove everything
make fclean
make all
```

## Security Considerations

1. **Environment Variables**: Never commit the `.env` file to git
2. **SSL/TLS**: Self-signed cert for development; use real certs for production
3. **Network**: Services communicate only on bridged networks, not exposed externally
4. **Database**: WordPress user limited to WordPress database only
5. **FTP**: Use SFTP or disable in production

## Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Reference](https://docs.docker.com/compose/compose-file/)
- [Nginx Documentation](https://nginx.org/en/docs/)
- [WordPress Development](https://developer.wordpress.org/)
- [MariaDB Documentation](https://mariadb.com/docs/)
