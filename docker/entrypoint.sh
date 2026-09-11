#!/bin/bash
set -e

# Wait for PostgreSQL
until pg_isready -h "${DB_HOST:-db}" -p "${DB_PORT:-5432}" -q; do
  echo "Waiting for PostgreSQL at ${DB_HOST:-db}..."
  sleep 1
done

# Prepare the database for the current RAILS_ENV (create + migrate, idempotent)
./bin/rails db:prepare

if [ "${SEED_ON_START}" = "true" ]; then
  echo "Seeding database..."
  ./bin/rails db:seed
fi

exec "$@"
