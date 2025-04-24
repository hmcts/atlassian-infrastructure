#!/bin/bash

# Print pre-requisites
echo "Ensure you have completed the following before running this script:"
echo
echo "1. You should have access to the atlassian key vault. This is required to retrieve the database password."
echo "2. You should have the Azure CLI installed and configured."
echo "3. You should have the PostgreSQL client installed and configured. This contains the pg_dump utility used by the script."
echo "4. You should stop the ${SERVICE} service to prevent a delta."
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
BACKUP_DIR="${DB_NAME}_backup_${TIMESTAMP}"

echo "Backing up database ${DB_NAME} to directory ${BACKUP_DIR}..."
# Run the pg_dump command
pg_dump -Fd -j 4 "$DB_NAME" -h "$DB_HOST" -p 5432 -U "$DB_USER" -f "$BACKUP_DIR" -v 2> backup.log

# Check if the backup was successful
if [ $? -eq 0 ]; then
    echo "Backup completed successfully. Directory: $BACKUP_DIR"
else
    echo "Backup failed. View backup.log for details."
fi

# Unset the PGPASSWORD environment variable for security
unset PGPASSWORD