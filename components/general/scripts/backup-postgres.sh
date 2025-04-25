#!/bin/bash

# Print pre-requisites
echo "Ensure you have completed the following before running this script:"
echo
echo "1. You should have access to the atlassian key vault. This is required to retrieve the database password."
echo "2. You should have the Azure CLI installed and configured."
echo "3. You should have the PostgreSQL client installed and configured. This contains the pg_dump utility used by the script."
echo "4. You should stop the appropriate service to prevent a delta."
echo
read -p "Have you completed the above? [y/n]: " CONFIRM

if [[ "$CONFIRM" != "y" ]]; then
	echo "Exiting script. Please complete the above steps before running this script."
	exit 1
fi
echo

# Prompt the user for input
read -p "Enter the environment you want to backup [nonprod|prod]: " ENVIRONMENT
read -p "Enter the service you want to backup [jira|confluence|crowd]: " SERVICE
read -p "Enter the hostname of the server you want to take a backup from: " DB_HOST
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
DB_USER="${SERVICE}_user"
DB_ADMIN="pgsqladmin"
UPPER_ENVIRONMENT=$(echo "$ENVIRONMENT" | tr a-z A-Z)

# Retrieve the database passwords from Azure Key Vault - typo in kv name
DB_ADMIN_PASSWORD=$(az keyvault secret show --name "${UPPER_ENVIRONMENT}-POSTGRES-FLEX-SERVER-PASS" --vault-name "atlasssian-${ENVIRONMENT}-kv" --query value -o tsv)
DB_PASSWORD=$(az keyvault secret show --name "${SERVICE}-db-${ENVIRONMENT}-postgres-password" --vault-name "atlasssian-${ENVIRONMENT}-kv" --query value -o tsv)

# Generate a timestamp for the backup file
TIMESTAMP=$(date +"%Y%m%d%H%M%S")
# Define the backup file name
BACKUP_DIR="${DB_NAME}_backup_${TIMESTAMP}"

export PGPASSWORD=$DB_ADMIN_PASSWORD
export PGHOST="${DB_HOST}"
export PGDATABASE="${DB_NAME}"
export PGUSER="${DB_ADMIN}"
export PGPORT=5432

# Grant admin role to user for backup
echo "Granting ${DB_ADMIN} role to ${DB_USER}..."
GRANT_ROLE_TO_USER="
GRANT \"${DB_ADMIN}\" TO \"${DB_USER}\";
"
psql "sslmode=require" -c "${GRANT_ROLE_TO_USER}"
if [ $? -ne 0 ]; then
	echo "Failed to grant ${DB_ADMIN} role to ${DB_USER}. Exiting."
	exit 1
fi

export PGPASSWORD=$DB_PASSWORD
echo "Backing up database ${DB_NAME} to directory ${BACKUP_DIR}..."
echo "You can monitor the progress by opening a new terminal and running: tail -f backup.log"
# Run the pg_dump command
pg_dump -Fd -j 4 "$DB_NAME" -h "$DB_HOST" -p 5432 -U "$DB_USER" -f "$BACKUP_DIR" -v 2> backup.log

# Check if the backup was successful
if [ $? -eq 0 ]; then
    echo "Backup completed successfully. Directory: $BACKUP_DIR"
else
    echo "Backup failed. View backup.log for details."
fi

export PGPASSWORD=$DB_ADMIN_PASSWORD
# Revoke admin role from user after backup
echo "Revoking ${DB_ADMIN} role from ${DB_USER}..."
REVOKE_ROLE_FROM_USER="
REVOKE \"${DB_ADMIN}\" FROM \"${DB_USER}\";
"
psql "sslmode=require" -c "${REVOKE_ROLE_FROM_USER}"
if [ $? -ne 0 ]; then
	echo "Failed to revoke ${DB_ADMIN} role from ${DB_USER}. Exiting."
	exit 1
fi

# Unset the environment variables for security
unset PGPASSWORD
unset PGHOST
unset PGDATABASE
unset PGUSER
unset PGPORT