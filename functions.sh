#!/bin/bash 

function checkConfigFile {

   if [ ! -f $CONFIG_FILE ]
   then 
     logit "No configuration file found [${CONFIG_FILE}]. Giving up"
     exit 1
   else 
     logit "Securing {$CONFIG_FILE}. Set it readonly" 
     chmod 400 $CONFIG_FILE
     chown root:root $CONFIG_FILE
   fi 

}

function createLog {

   if [ ! -d $LOG_DIR ]
   then 
      mkdir -p $LOG_DIR
   fi

}

function logit {
 
   echo "["$(date)"] $1" >> $LOG_FILE 

}

function createBackupDBDir {

  if [ ! -d $T3BACKUP_DBDIR ]
  then 
    logit "Creating ${T3BACKUP_DBDIR}"
    mkdir $T3BACKUP_DBDIR
  fi
}

function dumpDatabases {

   cd $MYSQL_DIR

   # create directory if not present

   for db in *
   do
      if [ -d "$db" ]
      then 
        #echo "Creating dump of mysql-db $db"
	DB_FILENAME="${db}.sql"
	DB_TMP_FILENAME="TMP-"$DB_FILENAME
	DUMP_CMD="mysqldump -uroot -p$MYSQL_ROOT_PW ${db}"
	logit "Dumping db $DB to ${DB_TMP_FILENAME}"
	$DUMP_CMD > ${T3BACKUP_DBDIR}/${DB_TMP_FILENAME}
	logit "Move to real name ${DB_TMP_FILENAME} -> ${DB_FILENAME}"
	mv ${T3BACKUP_DBDIR}/$DB_TMP_FILENAME ${T3BACKUP_DBDIR}/$DB_FILENAME 
      fi
   done
}

function getProtocol {

   PROT="sftp://"

   MAJOR_VERSION=$(cat /etc/debian_version | cut -d "." -f 1)

   case $MAJOR_VERSION in
     4)
        PROT="ssh://"
        ;;
     5)
        PROT="ssh://"
        ;;
     6)
        PROT="ssh://"
        ;;
     *)
        PROT="sftp://"
   esac

   # important, this returns the correct value
   echo $PROT

}

function createRemoteDir {

   REMOTEPATH=$SCP_BASE_DIR""$HOSTDIR
   DIRS=$1
   SFTP_CMD="mkdir ${REMOTEPATH}"

   for d in $(echo $DIRS | tr "/" "\n")
   do
      SFTP_CMD="${SFTP_CMD}""\n""mkdir ${REMOTEPATH}/${d}"
      REMOTEPATH="${REMOTEPATH}/${d}"
   done
   echo -e $SFTP_CMD | sftp $SCP_USER@$SCP_HOST
   
}

function isRemoteDir {


   #$1
   REMOTEPATH=$SCP_BASE_DIR""$HOSTDIR"/etc"
   echo "ls -la $REMOTEPATH"
   RESULT=$(ls -la $DIRS | sftp $SCP_USER@$SCP_HOST | head -n 2)
   echo $RESULT
}


