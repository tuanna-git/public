#!/bin/bash

# Set working directory
USER_HOME="$HOME"
NPM_DIR="$USER_HOME/nginx-proxy-manager"
BACKUP_DIR="$USER_HOME/npm-backup"
DB_FILE="$NPM_DIR/data/database.sqlite"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Ask for backup or restore
echo "Do you want to backup or restore?"
select OPTION in "Backup" "Restore" "Exit"; do
    case $OPTION in
        Backup)
            echo "Creating backup..."
            mkdir -p "$BACKUP_DIR"
            tar -czf "$BACKUP_DIR/npm_data_backup_$TIMESTAMP.tar.gz" -C "$NPM_DIR" .
            echo "Backup completed: $BACKUP_DIR/npm_data_backup_$TIMESTAMP.tar.gz"
            break
            ;;
        Restore)
            echo "Available backup files:"
            ls "$BACKUP_DIR"/*.tar.gz 2>/dev/null || { echo "No backup found."; exit 1; }
            echo "Enter the filename to restore (with extension):"
            read BACKUP_FILE
            if [ -f "$BACKUP_DIR/$BACKUP_FILE" ]; then
                echo "Stopping Docker..."
                docker compose -f "$NPM_DIR/docker-compose.yml" down
                echo "Restoring backup..."
                rm -rf "$NPM_DIR/data" "$NPM_DIR/letsencrypt"
                mkdir -p "$NPM_DIR"
                tar -xzf "$BACKUP_DIR/$BACKUP_FILE" -C "$NPM_DIR"
                echo "Starting Docker..."
                docker compose -f "$NPM_DIR/docker-compose.yml" up -d
                echo "Restore completed."
            else
                echo "Backup file not found: $BACKUP_DIR/$BACKUP_FILE"
            fi
            break
            ;;
        Exit)
            echo "Exiting."
            break
            ;;
        *)
            echo "Invalid option. Please choose again."
            ;;
    esac
done
