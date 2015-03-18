#!/bin/bash

CONFIG_FILE="/etc/t3backup/config.sh" 
# Set Root-Directory for backup on destination  
HOSTDIR=$(hostname -f)
T3BACKUP_DBDIR="/var/t3backupdbs"
# mysql path on server 
MYSQL_DIR=/var/lib/mysql
HELPER_FUNCTIONS="/usr/local/bin/t3backup/functions.sh"

# LOGS 
LOG_DIR=/var/log/t3backup
LOG_FILE="${LOG_DIR}/backup.log"
