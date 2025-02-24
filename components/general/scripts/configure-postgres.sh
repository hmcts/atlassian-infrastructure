#!/bin/bash
# set -x
#ensuring run
# Set up the database connection
export PGPORT=5432
export PGHOST="${POSTGRES_HOST}"
export PGUSER="${ADMIN_USER}"
export PGPASSWORD="${ADMIN_PASSWORD}"

# Create user
export PGDATABASE="postgres"
CREATE_USER="
CREATE ROLE \"${USER}\" WITH LOGIN PASSWORD '${PASSWORD}';
GRANT CONNECT ON DATABASE  \"${DATABASE_NAME}\" TO \"${USER}\";
ALTER ROLE \"${USER}\" WITH PASSWORD '${PASSWORD}';
"
psql "sslmode=require" -c "${CREATE_USER}"

# grant permissions
export PGDATABASE="${DATABASE_NAME}"
SQL_COMMAND="
GRANT USAGE ON SCHEMA public TO \"${USER}\";
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO \"${USER}\";
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO \"${USER}\";
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO \"${USER}\";
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO \"${USER}\";
"

# Run query
psql "sslmode=require" -c "${SQL_COMMAND}"

# Disable emails if DATABASE_NAME is jira-db-nonprod
if [ "${DATABASE_NAME}" = "jira-db-nonprod" ]; then
  DISABLE_EMAIL="UPDATE propertynumber SET propertyvalue = 1 WHERE \"id\" = (SELECT \"id\" FROM \"propertyentry\" WHERE \"property_key\" = 'jira.mail.send.disabled');"
  psql "sslmode=require" -c "${DISABLE_EMAIL}"
fi