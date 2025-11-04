# Pretix Docker Compose Setup

## Project Overview

This repository contains Docker Compose configurations for running [Pretix](https://pretix.eu/about/de/), an open-source ticket shop system, in containerized environments. The setup includes all necessary services to run Pretix, with different configurations for local development and production deployment on Dokploy.

### Architecture

The setup consists of three main services:

1. **app** - The main Pretix application container built from the official `pretix/standalone:stable` image
2. **database** - PostgreSQL database container for storing application data
3. **cache** - Redis container for caching and session storage

### Key Components

- **Docker Compose** - Orchestrates all services and their networking
- **PostgreSQL** - Main database for storing Pretix data
- **Redis** - Caching and session storage
- **Cron Jobs** - Automated periodic tasks for maintenance

## Building and Running

### Prerequisites

- Docker
- Docker Compose

### Starting the Services (Local Development)

To start and build all related containers for local development:

```bash
docker-compose up -d --build --force-recreate
```

This uses the default `docker-compose.yml` which includes Nginx and direct port mappings for local development.

### Ports (Local Development)

- **Port 80** - HTTP access to the Pretix application
- **Port 443** - HTTPS access to the Pretix application
- **Port 5432** - PostgreSQL database (for direct access)
- **Port 6379** - Redis cache (for direct access)

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

## Deployment on Dokploy

This repository has been configured to be deployable on [Dokploy](https://dokploy.com), an open-source self-hosted platform for container deployments. The setup uses Dokploy's default Traefik reverse proxy for automatic routing and SSL termination.

### Dokploy Deployment Steps

1. **Prepare environment variables**:
   - Copy `.env.example` to `.env` and adjust the values according to your environment
   - Add the environment variables in your Dokploy project settings

2. **Docker Compose Configuration**:
   - Use `docker-compose.dokploy.yml` for deployment on Dokploy
   - This configuration is optimized for Dokploy's environment with proper service discovery and Traefik integration

3. **Deploy on Dokploy**:
   - Add a new project in Dokploy
   - Select "Docker Compose" as the project type
   - Paste the contents of `docker-compose.dokploy.yml` in the compose field
   - Add environment variables from your `.env` file in the environment variables section
   - Set the DOMAIN environment variable to your desired domain name

4. **Required Environment Variables**:
   ```env
   POSTGRES_DB=pretix
   POSTGRES_USER=pretix
   POSTGRES_PASSWORD=pretix
   EMAIL_HOST=smtp.example.com
   EMAIL_PORT=587
   EMAIL_USER=your-smtp-username
   EMAIL_PASSWORD=your-smtp-password
   EMAIL_FROM=noreply@example.com
   PRETIX_INSTANCE_NAME=My Event Ticket Shop
   PRETIX_URL=https://your-domain.com
   PRETIX_CURRENCY=EUR
   PRETIX_DEFAULT_LOCALE=en
   PRETIX_TIMEZONE=Europe/Berlin
   DOMAIN=your-domain.com
   ```

### Dokploy-specific Notes

- The database is exposed on port 5432 within the Dokploy network
- The application service runs on port 80 internally
- SSL termination and routing is handled automatically by Dokploy's Traefik proxy
- Data persistence is managed through Dokploy's volume system
- The configuration uses the official `pretix/standalone:stable` image for optimal compatibility

## Customization

### Database Version

The local development setup uses PostgreSQL 17 for optimal compatibility.
The Dokploy setup uses PostgreSQL 12 to match official Pretix recommendations.

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
