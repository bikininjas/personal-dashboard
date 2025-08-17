#!/bin/bash
# Backup script for PostgreSQL
DATE=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_DIR="$(dirname "$0")"
PGUSER=vikunja
PGDATABASE=vikunja
PGHOST=localhost
PGPASSWORD=yourpassword
export PGUSER PGDATABASE PGHOST PGPASSWORD
pg_dump -Fc -f "$BACKUP_DIR/postgres_backup_$DATE.dump"
