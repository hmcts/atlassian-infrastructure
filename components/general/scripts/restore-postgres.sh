#!/bin/bash

# Prompt the user for input
read -p "Enter the environment you want to backup [nonprod|prod]: " ENVIRONMENT
read -p "Enter the service you want to backup [jira|confluence|crowd]: " SERVICE
read -p "Enter the hostname of the server you want to restore to: " DB_HOST
read -p "Enter the name of the backup directory: " BACKUP_FILE
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
DB_USER="pgsqladmin"
UPPER_ENVIRONMENT=$(echo "$ENVIRONMENT" | tr a-z A-Z)

# Retrieve the database admin password from Azure Key Vault - typo in kv name
DB_PASSWORD=$(az keyvault secret show --name "${UPPER_ENVIRONMENT}-POSTGRES-FLEX-SERVER-PASS" --vault-name "atlasssian-${ENVIRONMENT}-kv" --query value -o tsv)

# Set the PGPASSWORD environment variable for authentication
export PGPASSWORD=$DB_PASSWORD

# Create database to restore to
createdb "$DB_NAME" -h "$DB_HOST" -p 5432 -U "$DB_USER" 

# Check if the database creation was successful
if [ $? -ne 0 ]; then
		echo "Error: Failed to create temporary database $DB_NAME."
		exit 1
fi

# Run the pg_restore command
pg_restore -Fd -j 4 -d "$DB_NAME" "$BACKUP_FILE" -h "$DB_HOST" -p 5432 -U "$DB_USER" -v | tee restore.log

# Check if the backup was successful
if [ $? -eq 0 ]; then
    echo "Restore completed successfully."
else
    echo "Restore failed. View restore.log for details."
fi

# Unset the PGPASSWORD environment variable for security
unset PGPASSWORD