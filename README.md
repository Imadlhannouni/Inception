*This project has been created as part of the 42 curriculum by ilhannou.*

# Inception

## Description

Inception is a comprehensive Docker infrastructure project that implements a complete web hosting stack using Docker Compose. The project demonstrates containerization best practices by orchestrating multiple interconnected services to create a production-like environment.

### Project Goals

- Master Docker and container orchestration
- Understand multi-service architecture and networking
- Learn infrastructure as code principles
- Implement security best practices in containerized environments
- Manage persistent data in containerized applications

### Overview

The stack includes:
- **Nginx**: HTTPS-enabled web server and reverse proxy
- **WordPress**: Full-featured CMS application
- **MariaDB**: Relational database with persistent storage
- **Redis**: In-memory caching service
- **VSFTPD**: FTP server for file management
- **Adminer**: Web-based database administration tool
- **Portainer**: Docker container management UI
- **Static Website**: Bonus service for additional features

All services run in isolated Docker containers, communicate through secure networks, and store data in persistent volumes. The entire infrastructure is managed through a simple Makefile interface.

## Instructions

### Quick Start

```bash
# Build and start all services
make all

# Stop services (preserves data)
make stop

# Start previously stopped services
make start

# Complete restart
make re

# Remove containers and networks
make down

# Full cleanup including all data
make fclean
```

### Access Services

- **Website**: https://localhost/
- **WordPress Admin**: https://localhost/wp-admin/
- **Database Manager (Adminer)**: http://localhost:8080/
- **Container Manager (Portainer)**: https://localhost:9443/
- **Bonus Website**: http://localhost:8081/
- **FTP Server**: localhost:21

All credentials are configured in the `.env` file

### System Requirements

- Docker Engine 20.10+
- Docker Compose 2.0+
- 4GB RAM minimum
- 10GB free disk space
- Linux operating system

### Full Documentation

- **[USER_DOC.md](USER_DOC.md)** — Complete user guide with instructions for starting/stopping services, accessing applications, managing credentials, and troubleshooting
- **[DEV_DOC.md](DEV_DOC.md)** — Developer guide covering environment setup, building containers, managing volumes, service details, and development workflow

## Docker Architecture and Design Choices

### Project Overview: Docker vs Virtual Machines

The Inception project uses Docker containers instead of virtual machines for the following reasons:

#### Docker Advantages
- **Lightweight**: Containers share the host kernel; VMs include entire OS (100s of MB vs GBs)
- **Fast Startup**: Containers start in seconds; VMs take minutes
- **Efficient Resources**: Multiple containers use minimal overhead; VMs require dedicated CPU/RAM
- **Portability**: Same image runs identically on any Docker-enabled system
- **Simplicity**: Easier configuration and management compared to VM hypervisors

#### Virtual Machine Trade-offs
- Stronger isolation (each VM has separate kernel)
- More resource overhead
- Longer deployment times
- Less flexible for microservices architecture

**Choice for Inception**: Docker provides the optimal balance of isolation, efficiency, and ease of management for this multi-service infrastructure project.

---

### Secrets vs Environment Variables

The project uses a hybrid approach:

#### Configuration (`.env` file)
- **Location**: `srcs/.env`
- **Used for**: All service configuration and credentials
- **Advantages**:
  - Centralized configuration
  - Easy to override for different environments
  - Standard Docker/Compose practice
  - Supports dynamic values at runtime

#### Configuration Strategy
```
✓ Secrets for: passwords, authentication tokens, sensitive data
✓ Env vars for: service names, ports, non-sensitive configuration
✗ Hardcoded values: Never in source code
```

**Why not just environment variables for everything?**
- Environment variables visible in container inspection: `docker inspect`
- Secrets mounted as files are only accessible to processes that need them
- Production security best practice

---

### Docker Networks vs Host Network

The project uses Docker bridge networks (not host network):

#### Bridge Networks (Current Implementation)
```
Front Network  ←→  Nginx
Back Network   ←→  WordPress, MariaDB, Redis, VSFTPD, Adminer
```

**Advantages**:
- Service isolation: Internal services not directly exposed
- Network segmentation: Frontend and backend separated
- DNS resolution: Services reach each other by container name
- Security: Each network is a separate namespace
- Scalability: Easy to add/remove containers without port conflicts

**Configuration**:
```yaml
networks:
  Front:
    driver: bridge
  Back:
    driver: bridge
```

#### Host Network (Why not used here)
- All containers share host's network stack
- Simpler but less isolated
- Port conflicts likely with multiple services
- Services compete for same ports
- No network-level isolation

**Use cases for host network**: Single service per host, performance-critical applications

**Our Choice**: Bridge networks provide necessary isolation while maintaining all inter-service communication through the Docker network driver.

---

### Docker Volumes vs Bind Mounts

The project uses a combination of both:

#### Bind Mounts (WordPress and MariaDB)
```yaml
volumes:
  wordpress:
    driver: local
    driver_opts:
      type: 'none'
      o: 'bind'
      device: '/home/${USER}/data/wordpress'
  mariadb:
    driver: local
    driver_opts:
      type: 'none'
      o: 'bind'
      device: '/home/${USER}/data/mariadb'
```

**Advantages**:
- **Visibility**: Data accessible directly on host filesystem
- **Backup**: Easy `tar` or rsync operations
- **Development**: Edit files from host machine
- **Persistence**: Survive container recreation
- **Migration**: Simple file copying to new systems

**Disadvantages**:
- Performance overhead (especially on Mac/Windows with Docker Desktop)
- Permission management required
- File watching complexity
- Platform-dependent paths

#### Named Volumes (Portainer data)
```yaml
portainer_data:
  driver: local
```

**Advantages**:
- **Performance**: Better I/O performance than bind mounts
- **Management**: Docker manages the storage location
- **Backup**: Standard Docker volume backup tools
- **Portability**: Works across different systems

**Disadvantages**:
- Less visible from host (stored in Docker directory)
- Requires Docker commands for access
- Harder to edit files from host

#### Design Decision

| Data Type | Mount Type | Reason |
|-----------|-----------|--------|
| WordPress files | Bind Mount | Direct host access for content management, FTP access |
| Database files | Bind Mount | Backup/restore simplicity, direct filesystem operations |
| Portainer config | Named Volume | Better performance for internal configuration |

**Why bind mounts for application data?**
1. WordPress uploads managed through FTP (bind mount allows direct access)
2. Database backup/restore common operations (simplified with bind mount)
3. Development: Developers access data directly from host
4. Migration: Easy to backup and restore to other systems

---

## Technical Architecture

### Service Communication Flow

```
┌─────────────────────────────────────────┐
│          HTTPS (Port 443)               │
│  Browser → Nginx (Front Network)        │
└──────────────┬──────────────────────────┘
               │
        ┌──────▼──────┐
        │    Nginx    │ (Reverse Proxy)
        └──────┬──────┘
               │ (Internal)
        ┌──────▼──────────┐
        │   WordPress     │ (Front + Back)
        └──────┬──────────┘
               │ (Backend Network)
        ┌──────▼───────────────┬────────────┬──────────┐
        │                      │            │          │
    ┌───▼───┐            ┌────▼────┐  ┌───▼──┐  ┌───▼────┐
    │MariaDB│            │  Redis  │  │ FTP  │  │Adminer │
    └───────┘            └─────────┘  └──────┘  └────────┘
   (Database)           (Cache)     (Files)  (DB UI)
```

### Data Flow

1. **User Browser** → HTTPS request to Nginx (port 443)
2. **Nginx** → Routes to WordPress via internal Front network
3. **WordPress** → Queries database via Back network
4. **MariaDB** → Returns data via Back network
5. **Redis** → Caches responses for performance
6. **FTP** → Direct access to WordPress volume for file uploads
7. **Adminer** → Database administration via Back network

### Persistent Storage

```
/home/$USER/data/
├── wordpress/          ← Bind mount for WordPress files
│   ├── wp-config.php
│   ├── wp-content/
│   └── ... (all WordPress files)
└── mariadb/            ← Bind mount for database files
    ├── wordpress_db/
    ├── mysql/
    └── ... (all database data)
```

Data survives container restart/rebuild due to bind mounts.

---

## Design Rationale

### Why This Stack?

- **Nginx**: Lightweight, performant reverse proxy with HTTPS support
- **WordPress**: Industry-standard CMS with large ecosystem
- **MariaDB**: Open-source MySQL-compatible database
- **Redis**: Improves performance through caching
- **FTP**: Convenient file management interface
- **Adminer**: Lightweight database UI alternative to phpMyAdmin
- **Portainer**: Easy Docker management without CLI
- **Static Website**: Demonstrates multiple services on same host

### Security Approach

1. **Network Isolation**: Services on internal networks, only Nginx exposed
2. **Secret Management**: Passwords in gitignored files
3. **HTTPS**: TLS encryption for external traffic
4. **User Isolation**: Services run with limited privileges
5. **Volume Isolation**: Each service accesses only required volumes

---

## Resources

### Official Documentation
- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Reference](https://docs.docker.com/compose/compose-file/)
- [Nginx Web Server](https://nginx.org/en/docs/)
- [WordPress Development](https://developer.wordpress.org/)
- [MariaDB Server](https://mariadb.com/docs/)
- [Redis](https://redis.io/documentation)

### Tutorials and Guides
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Docker Networking](https://docs.docker.com/network/)
- [Multi-Container Applications](https://docs.docker.com/compose/gettingstarted/)
- [WordPress on Docker](https://hub.docker.com/_/wordpress)

### Related Technologies
- [SSL/TLS Certificates](https://en.wikipedia.org/wiki/Transport_Layer_Security)
- [FTP Protocol](https://tools.ietf.org/html/rfc959)
- [RESTful APIs](https://restfulapi.net/)

---

## AI Usage

AI was used to assist with:

- **Documentation Structure**: Organizing comprehensive user and developer documentation
- **Architecture Diagrams**: Planning service communication flows and network architecture
- **Best Practices**: Implementing Docker security and design patterns
- **Troubleshooting Guides**: Creating common issue resolution procedures
- **Code Examples**: Providing Docker Compose and Makefile command examples
- **Configuration Files**: Generating service configuration templates and examples

The core project implementation (Dockerfiles, service configuration, orchestration) was developed independently, with AI providing guidance on best practices and documentation completeness.

---

## Getting Started

1. **Read [USER_DOC.md](USER_DOC.md)** for operational instructions
2. **Check [DEV_DOC.md](DEV_DOC.md)** for development setup
3. **Run `make all`** to start the infrastructure
4. **Access https://localhost/** to view the website
5. **Refer to troubleshooting sections** for common issues

---

## License

Educational project created as part of the 42 curriculum.
