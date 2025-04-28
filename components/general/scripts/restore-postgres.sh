#!/bin/bash

# Print pre-requisites
echo "Ensure you have completed the following before running this script:"
echo
echo "1. You should have access to the atlassian key vault. This is required to retrieve the database password."
echo "2. You should have the Azure CLI installed and configured."
echo "3. You should have the PostgreSQL client installed and configured. This contains the pg_restore utility used by the script."
echo "4. You should stop the appropriate service to prevent a delta."
echo
read -p "Have you completed the above? [y/n]: " CONFIRM

if [[ "$CONFIRM" != "y" ]]; then
	echo "Exiting script. Please complete the above steps before running this script."
	exit 1
fi
echo

# Prompt the user for input
read -p "Enter the environment you want to restore [nonprod|prod]: " ENVIRONMENT
read -p "Enter the service you want to restore [jira|confluence|crowd]: " SERVICE
read -p "Enter the hostname of the server you want to restore to: " DB_HOST
read -p "Enter the name of the backup directory: " BACKUP_DIR
echo

# Validate the environment input
if [[ "$ENVIRONMENT" != "nonprod" && "$ENVIRONMENT" != "prod" ]]; then
	echo "Error: Invalid environment. Should be one of [nonprod|prod]."
	exit 1
fi
# Validate the service input
if [[ "$SERVICE" != "jira" && "$SERVICE" != "confluence" && "$SERVICE" != "crowd" ]]; then
	echo "Error: Invalid service. Should be one of [jira|confluence|crowd]."
	exit 1
fi
# Validate the hostname input
if [[ -z "$DB_HOST" ]]; then
	echo "Error: Hostname cannot be empty."
	exit 1
fi

# Set vars based on the environment and service
DB_NAME="${SERVICE}-db-${ENVIRONMENT}"
DB_ADMIN="pgsqladmin"
DB_USER="${SERVICE}_user"
UPPER_ENVIRONMENT=$(echo "$ENVIRONMENT" | tr a-z A-Z)

# Retrieve the database passwords from Azure Key Vault - typo in kv name
DB_ADMIN_PASSWORD=$(az keyvault secret show --name "${UPPER_ENVIRONMENT}-POSTGRES-FLEX-SERVER-PASS" --vault-name "atlasssian-${ENVIRONMENT}-kv" --query value -o tsv)
DB_PASSWORD=$(az keyvault secret show --name "${SERVICE}-db-${ENVIRONMENT}-postgres-password" --vault-name "atlasssian-${ENVIRONMENT}-kv" --query value -o tsv)

# Set connection parameters for configuring the database and permissions
export PGPASSWORD=$DB_ADMIN_PASSWORD
export PGHOST="${DB_HOST}"
export PGDATABASE="postgres"
export PGUSER="${DB_ADMIN}"
export PGPORT=5432

# Create the database if it doesn't exist
DB_EXISTS=$(psql "sslmode=require" -tAc "SELECT 1 FROM pg_database WHERE datname = '${DB_NAME}';")
if [ "$DB_EXISTS" != "1" ]; then
	echo "Database ${DB_NAME} does not exist. Creating it..."
	createdb -h "$DB_HOST" -p 5432 -U "$DB_ADMIN" "$DB_NAME" --lc-collate="en_US.UTF-8" --lc-ctype="en_US.UTF-8" --encoding="UTF-8" --template="template0"
	if [ $? -ne 0 ]; then
		echo "Failed to create database ${DB_NAME}. Exiting."
		exit 1
	fi
else
	echo "Database ${DB_NAME} already exists. Proceeding with restore."
fi

# Create the user if it doesn't exist
USER_EXISTS=$(psql "sslmode=require" -tAc "SELECT 1 FROM pg_roles WHERE rolname = '${DB_USER}';")
if [ "$USER_EXISTS" != "1" ]; then
	echo "User ${DB_USER} does not exist. Creating it..."
	CREATE_USER="
	CREATE ROLE \"${DB_USER}\" WITH LOGIN PASSWORD '${DB_PASSWORD}';
	GRANT CONNECT ON DATABASE  \"${DB_NAME}\" TO \"${DB_USER}\";
	ALTER ROLE \"${DB_USER}\" WITH PASSWORD '${DB_PASSWORD}';
	"
	psql "sslmode=require" -c "${CREATE_USER}"
	if [ $? -ne 0 ]; then
		echo "Failed to create user ${DB_USER}. Exiting."
		exit 1
	fi
else
	echo "User ${DB_USER} already exists. Proceeding with restore."
fi

# Grant permissions to public schema
export PGDATABASE="${DB_NAME}"
echo "Granting permissions to public schema for ${DB_USER}..."
GRANT_PERMISSIONS="
GRANT USAGE ON SCHEMA public TO \"${DB_USER}\";
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO \"${DB_USER}\";
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO \"${DB_USER}\";
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO \"${DB_USER}\";
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO \"${DB_USER}\";
"
# Run query
psql "sslmode=require" -c "${GRANT_PERMISSIONS}"

if [ $? -ne 0 ]; then
	echo "Failed to grant permissions to on public schema to ${DB_USER}. Exiting."
	exit 1
fi
echo "Permissions granted successfully."

# Grant user role to admin for restore
echo "Granting ${DB_USER} role to ${DB_ADMIN}..."
GRANT_ROLE_TO_ADMIN="
GRANT \"${DB_USER}\" TO \"${DB_ADMIN}\";
"
psql "sslmode=require" -c "${GRANT_ROLE_TO_ADMIN}"
if [ $? -ne 0 ]; then
	echo "Failed to grant ${DB_USER} role to ${DB_ADMIN}. Exiting."
	exit 1
fi

echo "Restoring database ${DB_NAME} from directory ${BACKUP_DIR}..."
echo "You can monitor the progress by opening a new terminal and running: tail -f restore.log"
# Run the pg_restore command
pg_restore -Fd -j 4 -d "$DB_NAME" "$BACKUP_DIR" -h "$DB_HOST" -p 5432 -U "$DB_ADMIN" -v 2> restore.log

# Check if the restore was successful
echo "Restore complete. View restore.log for details."

# Revoke user role from admin after restore
echo "Revoking ${DB_USER} role from ${DB_ADMIN}..."
REVOKE_ROLE_FROM_ADMIN="
REVOKE \"${DB_USER}\" FROM \"${DB_ADMIN}\";
"
psql "sslmode=require" -c "${REVOKE_ROLE_FROM_ADMIN}"
if [ $? -ne 0 ]; then
    echo "Failed to revoke ${DB_USER} role from ${DB_ADMIN}. Please check manually."
fi

# Disable emails if DATABASE_NAME is jira-db-nonprod
if [ "${DATABASE_NAME}" == "jira-db-nonprod" ]; then
	# Check if the table 'propertynumber' exists
	echo "Checking if the 'propertynumber' table exists..."
	TABLE_EXISTS=$(psql "sslmode=require" -tAc "SELECT EXISTS (SELECT 1 FROM pg_catalog.pg_tables WHERE schemaname = 'public' AND tablename = 'propertynumber');")

	# If the table exists, run the query to disable emails
	if [ "${TABLE_EXISTS}" == "t" ]; then
		echo "Disabling emails in the 'propertynumber' table..."
		DISABLE_EMAIL="UPDATE propertynumber SET propertyvalue = 1 WHERE \"id\" = (SELECT \"id\" FROM \"propertyentry\" WHERE \"property_key\" = 'jira.mail.send.disabled');"
		psql "sslmode=require" -c "${DISABLE_EMAIL}"

		if [ $? -eq 0 ]; then
			echo "Emails disabled successfully."
		else
			echo "Failed to disable emails. You should do this manually."
		fi
	else
		echo "Table 'propertynumber' does not exist. Skipping disable email query."
	fi
fi

# Unset PostgreSQL environment variables for security
unset PGPASSWORD
unset PGUSER
unset PGDATABASE
unset PGHOST
unset PGPORT
