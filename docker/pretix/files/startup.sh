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

# The pretix/standalone image uses supervisor to manage services
# Based on the Dockerfile, the crond.conf is already configured to run cron
# So let's just ensure that the services started by supervisor are running properly
# The pretix runperiodic command should be handled by our custom cron implementation

# Start the celery worker
# Using the pretix command if available, otherwise fall back to celery directly
if command -v pretix &> /dev/null; then
    # The 'runworker' command is the correct way to start the celery worker in newer versions
    pretix runworker &
else
    # Fallback to using celery directly if the pretix command doesn't support it
    celery -A pretix.celery_app worker --loglevel=INFO -E &
fi

# Start the web server
exec "$@"