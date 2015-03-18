#!/bin/bash 

ERROR=0
PHP=$(which php)
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CONFIG_DEFAULT_FILE=$DIR"/config.default.sh"
. $CONFIG_DEFAULT_FILE
. $HELPER_FUNCTIONS
. $HELPER_SYNTAX

createLog 
checkConfigFile 

. $CONFIG_FILE

# As we are working remote, we need to unset
# - HOSTDIR
# - DUPLICITY_PASS_PHRASE 
# -> that seems to be the only difference to a local recover
HOSTDIR=""
DUPLICITY_PASS_PHRASE=""

# Check Options
for i in "$@"
do
case $i in
    -h=*|--host=*)
      HOSTDIR="${i#*=}"
      shift
    ;;
    -s=*|--srcdb=*)
      SRC_DB="${i#*=}"
      shift
    ;;
    -d=*|--destdb=*)
      DEST_DB="${i#*=}"
    ;;
    -p=*|--duppass=*)
      DUPLICITY_PASS_PHRASE="${i#*=}"
      shift
    ;;
    *)
    # unknown option
    ;;
esac
done

if [ "$HOSTDIR" == "" ]
then
  echo "You need to pass the HOSTDIR by -h or --host"
  ERROR=1
fi

if [ "$SRC_DB" == "" ]
then
  echo "You need to pass the SOURCE_DB by -s or --srcdb"
  ERROR=1
fi

if [ "$DEST_DB" == "" ]
then
  echo "You need to pass the DESTDB by -d or --destdb"
  ERROR=1
fi

if [ "$DUPLICITY_PASS_PHRASE" == "" ]
then 
  echo "You need to pass the DUPLICITY_PASS_PHRASE by -p or --duppass"
  ERROR=1  
fi

if [ "$ERROR" == 1 ]
then
  echo "ERROR"
  syntax_db 
  exit 1
fi


BACKUPDBDIR="/var/t3backupdbs/"
DESTDBDIR=$(mktemp -d)

# This what we run
echo "SRC_HOST:              ${HOSTDIR}"
echo "SRC_DIR_ABS:           ${BACKUPDIR}"
echo "DEST_DIR_ABS:          ${DESTDIR}"
echo "DUPLICITY_PASS_PHRASE: xxxxxxxx"

#
FULL_PATH="${SCP_BASE_DIR}${HOSTDIR}"

# This way it will not appear in any logs
export MYSQL_ROOT_PW
export PASSPHRASE=$DUPLICITY_PASS_PHRASE
CMD="duplicity restore --file-to-restore=${SRC_DB}.sql "$(getProtocol)"${SCP_USER}@${SCP_HOST}${FULL_PATH}${BACKUPDBDIR} ${DESTDBDIR}/${DEST_DB}.sql"
$CMD

echo "RESULT of db-restore:(0 is good)->"$?

if [ -f "${DESTDBDIR}/${DEST_DB}.sql" ]
then
  echo "-- Creating DB -- "
  echo "CREATE DATABASE IF NOT EXISTS $DEST_DB" | mysql -uroot -p"$MYSQL_ROOT_PW"
  echo "Result of Creation of Database:"$?
  
  echo "-- Importing DB --"
  mysql -uroot -p"$MYSQL_ROOT_PW" $DEST_DB < $DESTDBDIR/${DEST_DB}".sql"
  echo "Result of Database Import:"$?
  echo "Database created and data imported"
else
  echo "Sorry. Database not found at $DESTDBDIR/$DEST_DB.sql.. Giving up"
  exit 1
fi

rm -fR $DESTDBDIR
echo "Result of Removing $DESTDBDIR:"$?


unset PASSPHRASE

echo "-- Ready @ "$(date)
