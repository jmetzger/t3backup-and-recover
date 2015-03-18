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
    -s=*|--srcproj=*)
      SRC_PROJECT="${i#*=}"
      shift
    ;;
    -d=*|--destproj=*)
      DEST_PROJECT="${i#*=}"
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

if [ "$SRC_PROJECT" == "" ]
then
  echo "You need to pass the SOURCE_PROJECT by -s or --src_proj"
  ERROR=1
fi

if [ "$DEST_PROJECT" == "" ]
then
  echo "You need to pass the DEST_PROJECT by -d or --dest_proj"
  ERROR=1
fi

if [ "$DUPLICITY_PASS_PHRASE" == "" ]
then 
  echo "You need to pass the DUPLICITY_PASS_PHRASE by -p or --duplicity_pass_phrase"
  ERROR=1  
fi

if [ "$ERROR" == 1 ]
then
  echo "ERROR"
  syntax 
  exit 1
fi


# inserted manually 
# 
BACKUPDIR="/var/customers/webs/${SRC_PROJECT}"
DESTDIR="/var/customers/webs/${DEST_PROJECT}"
BACKUPDBDIR="/var/t3backupdbs/"
DESTDBDIR=$(mktemp -d)

# This what we run
echo "SRC_HOST:              ${HOSTDIR}"
echo "SRC_DIR_ABS:           ${BACKUPDIR}"
echo "DEST_DIR_ABS:          ${DESTDIR}"
echo "DUPLICITY_PASS_PHRASE: xxxxxxxx"

#
FULL_PATH="${SCP_BASE_DIR}${HOSTDIR}"


echo "-- Starting @ "$(date)

# Helper Script to recover a specific web project 
# you do not necessary mention 'restore' 
export PASSPHRASE=$DUPLICITY_PASS_PHRASE
duplicity restore $(getProtocol)$SCP_USER@$SCP_HOST""${FULL_PATH}${BACKUPDIR} ${DESTDIR}
echo "Result of file-restore ${BACKUPDIR} "$?

APP=$($PHP $DIR/helpers/detectApp.php $DESTDIR)
if [ -f $DIR/helpers/clearCache_$APP.sh ]
then
  echo "yes found"
  /bin/bash $DIR/helpers/clearCache_$APP.sh $DESTDIR
else 
  echo "nope, not presnt"
fi

# Helper Script to extract 
DB=$($PHP $DIR/helpers/extractDb.php $DESTDIR)
echo "-->"$DB"<--"

# This way it will not appear in any logs
export MYSQL_ROOT_PW
$PHP $DIR/helpers/createDbUser.php $DESTDIR

CMD="duplicity restore --file-to-restore=${DB}.sql "$(getProtocol)"${SCP_USER}@${SCP_HOST}${FULL_PATH}${BACKUPDBDIR} ${DESTDBDIR}/${DB}.sql"
$CMD
echo "RESULT of db-restore:(0 is good)->"$?

if [ -f "${DESTDBDIR}/${DB}.sql" ]
then
  echo "-- Creating DB -- "
  echo "CREATE DATABASE IF NOT EXISTS $DB" | mysql -uroot -p"$MYSQL_ROOT_PW"
  echo "Result of Creation of Database:"$?
  
  echo "-- Importing DB --"
  mysql -uroot -p"$MYSQL_ROOT_PW" $DB < $DESTDBDIR/${DB}".sql"
  echo "Result of Database Import:"$?
  echo "Database created and data imported"
else
  echo "Sorry. Database not found at $DESTDBDIR/$DB.sql.. Giving up"
  exit 1
fi

rm -fR $DESTDBDIR
echo "Result of Removing $DESTDBDIR:"$?


unset PASSPHRASE

echo "-- Ready @ "$(date)
