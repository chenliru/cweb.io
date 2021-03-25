#!/usr/bin/ksh
################################################################################
#
# Name: 	ids.ontape.bkup
#
# Reference:    n/a
#
# Description:  The ontape utility:
#               1. Back up and restore storage spaces and logical logs. 
#               2. Change database-logging mode with a level-0 backup. 
#                  - An unbuffered log mode to an ANSI log mode 
#                  - An unbuffered log mode to a buffered log mode 
#                  - A buffered log mode to an unbuffered log mode 
#               3. Start continuous logical-log backups. 
#               4. Use data replication. 
#               5. Rename chunks to different pathnames and offsets.
#
################################################################################
set -v
set -x

if [[ $# != 2 ]]
then
  echo $"Usage: $0 informix_instance backup_device"
  exit 1
fi

if [[ $USER != root ]]
then
  echo "You should be root user"
  exit 2
fi

#Setting scritps environment parameters
. ~/tools.profile

instance=${1-$IDSSERVER}
bkupdev=${2-$BACKUPDEVICE}

. $TOOLSDIR/db/informix/$IDSENV $instance

# Create a backup while the database server is online or in quiescent mode
# Use "onmode -u", change to quiescent mode and kill all attached sessions

typeset dbstate="On-Line"
#or typeset dbstate="Quiescent"
currstate=`onstat - | grep Informix | awk '{ print $8 }'`

if [[ $dbstate != $currstate ]]
  then
    echo "\nBackup can not be processed due to database is not up!"
    echo "\nRe-run this script when database is up!"
    exit
  else
    echo "\nDatabase is up and running ....\n"
fi

date > $LOGFILE

# If backup device is tape drive, load tape volume
[[ $bkupdev = /dev/rmt* ]] && util.tape $bkupdev load

echo "\nBackUp Configuration Files ... " >> $LOGFILE
# Keep a copy of the current onconfig/sqlhosts files when you create a level-0 backup. 
# You need this information to restore database server data from the backup tape.

[[ -z $INFORMIXSQLHOSTS ]] && INFORMIXSQLHOSTS=$INFORMIXDIR/etc/sqlhosts
[[ -f ~/.netrc ]] && cp ~/.netrc $TOOLSDIR/db/informix/etc/NETRC.$instance

cp $INFORMIXDIR/etc/$ONCONFIG $TOOLSDIR/db/informix/etc/ONCONFIG.$instance
cp $INFORMIXSQLHOSTS $TOOLSDIR/db/informix/etc/SQLHOSTS.$instance
cp /etc/services $TOOLSDIR/db/informix/etc/SERVICES.$instance

onstat -D | grep -v pathname | grep / | awk '{print $7}' \
          > $TOOLSDIR/db/informix/etc/CHUNK.$instance
echo "BACKUP DEVICE:     $bkupdev" \
          >> $TOOLSDIR/db/informix/etc/CHUNK.$instance

echo "\nLevel 0 $instance Database Backup to $bkupdev...." >> $LOGFILE
echo " " 
# A backup could take lots of tapes, when one becomes full,the ontape utility rewinds the tape,
# displays the tape number for labeling, and prompts the operator to mount the next tape when 
# you need another one. Just follow the prompts for labeling and mounting new tapes.

 if [[ $instance = "ardb" ]]; then
 # Livingston Archive DB needs two tapes, we have to manually change tape when first tape full
 ontape -s -L 0 -t $bkupdev|tee -a $LOGFILE

 else

ontape -s -L 0 -t $bkupdev<<EOF
^M
^M
EOF

 fi

[[ $? != 0 ]] && {
  echo "$instance Database Backup Failed" >> $ERRFILE
  exit 2
  }

echo "Backup is completed successfully, please check the mail ...\n"
mail -s "Informix $instance backup completed successfully (`hostname`) @ `date`" $SYSADMEMAIL \
        < $LOGFILE

# umount tape in TapeDrive
[[ $bkupdev = /dev/rmt* ]] && util.tape $bkupdev offline 

exit 0 
