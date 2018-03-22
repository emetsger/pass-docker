#!/bin/ash

set -v

echo "Initializing 'dspace' database" 2>&1 >/dev/null
env
createuser --username=postgres --no-superuser dspace
createdb --username=postgres --owner=dspace --encoding=UNICODE dspace
psql --username=postgres dspace -c "CREATE EXTENSION pgcrypto;"
sed -e "s:^#port = 5432:port = ${POSTGRES_DB_PORT}:" -i /var/lib/postgresql/data/postgresql.conf