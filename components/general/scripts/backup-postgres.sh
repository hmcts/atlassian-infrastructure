#!/bin/bash

# Prompt the user for input
read -p "Enter the environment you want to backup [nonprod|prod]: " ENVIRONMENT
read -p "Enter the service you want to backup [jira|confluence|crowd]: " SERVICE
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

# Set vars based on the environment and service
DB_HOST="atlassian-${ENVIRONMENT}-flex-server.postgres.database.azure.com"
DB_NAME="${SERVICE}-db-${ENVIRONMENT}"
DB_USER="${SERVICE}_user"

# Retrieve the database password from Azure Key Vault - typo in kv name
DB_PASSWORD=$(az keyvault secret show --name "${SERVICE}-db-${ENVIRONMENT}-postgres-password" --vault-name "atlasssian-${ENVIRONMENT}-kv" --query value -o tsv)

# Set the PGPASSWORD environment variable for authentication
export PGPASSWORD=$DB_PASSWORD

# Generate a timestamp for the backup file
TIMESTAMP=$(date +"%Y%m%d%H%M%S")

# Define the backup file name
BACKUP_FILE="${DB_NAME}_backup_${TIMESTAMP}"

# Run the pg_dump command
pg_dump -Fd -j 4 "$DB_NAME" -h "$DB_HOST" -p 5432 -U "$DB_USER" -f "$BACKUP_FILE" -v | tee backup.log

# Check if the backup was successful
if [ $? -eq 0 ]; then
		echo
    echo "Backup completed successfully. File: $BACKUP_FILE"
else
		echo
    echo "Backup failed. View backup.log for details."
fi

# Unset the PGPASSWORD environment variable for security
unset PGPASSWORD