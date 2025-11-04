# Pretix Docker Compose Setup

## Project Overview

This repository contains a Docker Compose configuration for running [Pretix](https://pretix.eu/about/de/), an open-source ticket shop system, in a containerized environment. The setup includes all necessary services to run Pretix locally for development purposes, including the application server, PostgreSQL database, and Redis cache.

### Architecture

The setup consists of three main services:

1. **app** - The main Pretix application container built from the official `pretix/standalone:stable` image
2. **database** - PostgreSQL 17 database container for storing application data
3. **cache** - Redis container for caching and session storage

### Key Components

- **Docker Compose** - Orchestrates all services and their networking
- **Nginx** - Handles web server functionality, SSL termination, and static file serving
- **PostgreSQL** - Main database for storing Pretix data (version 17)
- **Redis** - Caching and session storage
- **Cron Jobs** - Automated periodic tasks for maintenance

## Building and Running

### Prerequisites

- Docker
- Docker Compose

### Starting the Services

To start and build all related containers:

```bash
docker-compose up -d --build --force-recreate
```

### Ports

- **Port 81** - HTTP access to the Pretix application
- **Port 444** - HTTPS access to the Pretix application
- **Port 5432** - PostgreSQL database (for direct access)
- **Port 6379** - Redis cache (for direct access)

### TLS Setup

The application supports TLS certificates. You can:

1. Use your own certificates by mounting them to:
   - Certificate: `docker/pretix/files/config/ssl/domain.crt`
   - Key: `docker/pretix/files/config/ssl/domain.key`

2. Generate self-signed certificates using the script in `scripts/create-tls-certs.sh`

3. Customize the Nginx configuration in `docker/pretix/nginx/nginx.conf`

## Configuration

### Application Configuration

The main Pretix configuration is in `docker/pretix/pretix.cfg`:

- Instance name: localhost
- Database connection to the PostgreSQL service
- Redis caching configuration
- Email settings (requires customization for proper email functionality)

### Cron Jobs

Periodic tasks are configured in `docker/pretix/crontab`:
- Runs `pretix runperiodic` every hour at 15 and 45 minutes past the hour

### Volumes

- `pretix_data` - Persistent storage for Pretix data and media files
- `postgres_data` - Persistent storage for the PostgreSQL database

## Customization

### Database Version

The setup currently uses PostgreSQL 17 (as of version 1.2.0). Previous versions used different PostgreSQL versions.

### Nginx Configuration

The Nginx configuration is located in `docker/pretix/nginx/nginx.conf` and can be modified to:
- Update SSL settings
- Customize static file handling
- Modify proxy settings

### Environment Variables

The database service can be customized through environment variables in the docker-compose.yml file:
- `POSTGRES_USER` - Database user (default: pretix)
- `POSTGRES_PASSWORD` - Database password (default: pretix)

## Development Conventions

This is a Docker-based setup for Pretix, which is written in Python using the Django web framework. The repository focuses on containerization and orchestration rather than direct code modifications to Pretix itself.

## Troubleshooting

1. **Service startup issues**: Check that all volumes are properly created and accessible
2. **Database connection errors**: Ensure the database service starts before the app service
3. **SSL certificate issues**: Verify that certificates are properly mounted in the expected location

## Contributing

Contributions can be made by opening pull requests on the repository. The setup is designed for local development and testing of Pretix.

## License

This project is available under the Apache 2.0 license.