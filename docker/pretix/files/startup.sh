#!/bin/bash

# Wait for the database to be ready
until pg_isready -h $PRETIX_DB_HOST -U $PRETIX_DB_USER -d $PRETIX_DB_NAME
do
    echo "Waiting for database connection..."
    sleep 5
done

# Run database migrations if needed
pretix migrate --no-input

# Start the celery worker in the background
pretix celery worker --detach --loglevel=INFO &

# Start the cron process in the background
pretix cron --detach --loglevel=INFO &

# Start the web server
exec "$@"