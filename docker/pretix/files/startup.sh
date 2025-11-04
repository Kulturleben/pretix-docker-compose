#!/bin/bash

# Print environment variables for debugging
echo "PRETIX_URL is: $PRETIX_URL"
echo "PRETIX_INSTANCE_NAME is: $PRETIX_INSTANCE_NAME"
echo "PRETIX_DB_HOST is: $PRETIX_DB_HOST"
echo "PRETIX_DB_NAME is: $PRETIX_DB_NAME"
echo "PRETIX_DB_USER is: $PRETIX_DB_USER"
echo "PRETIX_DB_PASSWORD is: $PRETIX_DB_PASSWORD"

# Wait for the database to be ready
until pg_isready -h $PRETIX_DB_HOST -U $PRETIX_DB_USER -d $PRETIX_DB_NAME
do
    echo "Waiting for database connection..."
    sleep 5
done

# Run database migrations if needed
python -m pretix migrate --no-input

# The pretix/standalone image uses supervisor to manage services appropriately
# The supervisor configuration already includes the celery worker, cron, web server, etc.
# So we just need to ensure the environment is set up and let supervisor handle services

# Start the web server and let supervisor manage other services
exec "$@"