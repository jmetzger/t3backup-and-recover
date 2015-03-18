#!/bin/bash 

CONFIG_DEFAULT_FILE="/usr/local/bin/t3backup/config.default.sh"
. $CONFIG_DEFAULT_FILE
. $HELPER_FUNCTIONS

createLog 
checkConfigFile 

. $CONFIG_FILE
TO_BACKUP_DIR=$TO_BACKUP_DIR" "$T3BACKUP_DBDIR

logit "-- noop --"
logit "-- noop --"
logit "--"
logit "[Step 00] Starting Backup on ${HOST_DIR}"

echo $(createBackupDBDir)

logit "[Step 01]: Dumping Databases"
echo $(dumpDatabases)

# Simple duplicity scripting 
logit "[Step 02] - Backing up ${TO_BACKUP_DIR}" 

for i in $TO_BACKUP_DIR
do
  FULL_PATH="${SCP_BASE_DIR}${HOSTDIR}${i}"
  logit "[Step 02-${i}] Backup ${i} with Duplicity to ${FULL_PATH}"

  # 'hidrive' isset in /root/.ssh/config -> alias
  RESULT=$(echo "ls -la $FULL_PATH" | sftp ${SCP_USER}@${SCP_HOST} | head -n 2 | tr -s " " | cut -d" " -f 9)
  
  RESULT=${RESULT: -1}
  if [ "$RESULT" == "." ]
  then
     echo "Directory Exists"
  else 
     logit "[Step 02x] Directory $i does not exist yet -> creating it"
     createRemoteDir $i
  fi
  
  export PASSPHRASE=$DUPLICITY_PASS_PHRASE
  CMD="duplicity $i $(getProtocol)$SCP_USER@$SCP_HOST""$FULL_PATH"
  logit "[Step 02x] Executing command : $CMD"
  $CMD
  
  RESULT=$? 
  logit "How succesful was this ?"$RESULT
  unset PASSPHRASE
done

logit "[Step 03] Backup Done ! YEAH"





