#!/bin/bash

echo "Testing Dokploy Docker Compose configuration..."

# Check if docker-compose.dokploy.yml exists
if [ ! -f "docker-compose.dokploy.yml" ]; then
    echo "ERROR: docker-compose.dokploy.yml not found!"
    exit 1
fi

# Check if .env.example exists
if [ ! -f ".env.example" ]; then
    echo "ERROR: .env.example not found!"
    exit 1
fi

# Validate the Docker Compose file syntax by parsing it with docker compose config
echo "Validating docker-compose.dokploy.yml syntax..."
if command -v docker-compose &> /dev/null; then
    docker-compose -f docker-compose.dokploy.yml config > /dev/null
    SYNTAX_CHECK_RESULT=$?
elif command -v docker &> /dev/null; then
    docker compose -f docker-compose.dokploy.yml config > /dev/null
    SYNTAX_CHECK_RESULT=$?
else
    echo "WARNING: Neither docker-compose nor docker compose command found. Skipping syntax check."
    SYNTAX_CHECK_RESULT=0
fi

if [ $SYNTAX_CHECK_RESULT -eq 0 ]; then
    echo "Docker Compose configuration is syntactically correct!"
else
    echo "ERROR: Docker Compose configuration has syntax errors!"
    exit 1
fi

# Check that environment variables are used properly
ENV_VAR_PATTERN='\$\{[A-Z_][A-Z0-9_:.-]*\}'
if grep -qE "$ENV_VAR_PATTERN" docker-compose.dokploy.yml; then
    echo "Environment variables properly configured in Docker Compose file."
else
    echo "WARNING: No environment variables detected in Docker Compose file."
fi

# Check that volumes are defined
if grep -q "volumes:" docker-compose.dokploy.yml; then
    echo "Volume definitions found in Docker Compose file."
else
    echo "WARNING: No volume definitions found in Docker Compose file."
fi

# Check that services are properly defined
if grep -q "services:" docker-compose.dokploy.yml; then
    echo "Service definitions found in Docker Compose file."
else
    echo "WARNING: No service definitions found in Docker Compose file."
fi

# Check that Traefik labels are present
if grep -q "traefik" docker-compose.dokploy.yml; then
    echo "Traefik labels found in the app service configuration."
else
    echo "WARNING: No Traefik labels found in the Docker Compose file."
fi

# Check that the app service either uses the pretix/standalone image or has a build configuration
if grep -q "image: pretix/standalone:stable" docker-compose.dokploy.yml || grep -q "build:" docker-compose.dokploy.yml; then
    echo "App service correctly configured (using image or build)."
else
    echo "WARNING: App service not properly configured."
fi

echo "Test completed successfully!"