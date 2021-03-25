#!/usr/bin/ksh
##############################################################################################
#
# Name: 	ids.ontape.rest
#
# Reference:    n/a
#
# Description: 
#    1. To configure the database server environment, verify that the following environment 
#       variables are set correctly: 
#       INFORMIXDIR: is set to the full path of the IBM® Informix® directory. 
#       INFORMIXSERVER: is set to the name of the default database server. 
#       INFORMIXSQLHOSTS: is set to the full path to the SQLHOSTS file (UNIX) 
#                        or the SQLHOSTS registry host machine (Windows). 
#       DELIMIDENT: is not set or set to n. Enterprise Replication does not allow 
#                  delimited identifiers
#
#       . $IDSENV $instance
#
#    2. Verify that the raw devices or files that you used for storage (of the storage spaces 
#       being restored) after the level-0 backup are available.
#    
#       ./ids.create.chunk $instance
#
#    3. Gather the appropriate backup and logical-log tapes,use ontape to perform the backup 
#       tasks. With ontape utility:
#       -r option to perform a full physical and logical restore of the database server data. 
#       -D option to restore selected storage spaces. 
#       -rename option to rename chunks during the restore
#    
#    The database server is offline when you begin a cold restore but it goes into recovery
#    mode after it restores the reserved pages. From that point on it stays in recovery 
#    mode until either a logical restore finishes (after which it works in quiescent mode) 
#    or you use the onmode utility to shift it to another mode.
#
#    In the next example, assume that the TAPEDEV configuration parameter is not set. 
#    The following command loads data into the secondary server of an HDR pair 
#    (named secondary_host):
#
#    ontape -s -L 0 -F -t STDIO | rsh secondary_host "ontape -t STDIO -p" 
#
#    The examples perform a fake level-0 archive of the database server on the local computer, 
#    pipe the data to the remote computer by using the rsh system utility, and perform a 
#    physical restore on the remote computer by reading the data directly from the pipe.
#
#    Important: The previous examples require that the INFORMIXDIR, INFORMIXSERVER, 
#    INFORMIXSQLHOSTS, and ONCONFIG environment variables be set in the default environment 
#    for the user on the remote computer on which the command is executed. The user must be 
#    informix or root.
#
#    4. Use the RENAME DATABASE statement to change the name of a database
#       RENAME DATABASE owner.old_database TO new_database
#
#    5. Use onmode -m to bring informix db on-Line
###############################################################################################
#set -v
#set -x

if [[ $# != 2 ]]
then
  echo $"Usage: $0 informix_instance "
  exit 1
fi

if [[ $USER != 'root' ]]
then
  echo "You should be root user"
  exit 2
fi

. ~/tools.profile

instance=${1-$IDSSERVER}
bkupdev=$(grep "BACKUP DEVICE" $TOOLSDIR/db/informix/etc/CHUNK.$instance | awk '{print $3}')

. $TOOLSDIR/db/informix/$IDSENV $instance

date > $LOGFILE

echo "\nLevel 0 $Instance Database Restore start...." >> $LOGFILE            
echo " Warning: This is the last chance to STOP Database Restore..."
echo " CONTROL+C to STOP Restore process, which may DISTROY current Database..."

sleep 60

echo "\nRestore Configuration Files ... " >> $LOGFILE
# Find the latest copy of the onconfig/sqlhosts files when you create a level-0 backup. 
# You need this information to restore database server data from the backup tape.

[[ -z $INFORMIXSQLHOSTS ]] && INFORMIXSQLHOSTS=$INFORMIXDIR/etc/sqlhosts

cp $INFORMIXDIR/etc/$ONCONFIG $INFORMIXDIR/etc/$ONCONFIG.$TOOLSID.bkup
cp $INFORMIXSQLHOSTS $INFORMIXSQLHOSTS.$TOOLSID.bkup

cp $TOOLSDIR/db/informix/etc/ONCONFIG.$instance $INFORMIXDIR/etc/$ONCONFIG 
cp $TOOLSDIR/db/informix/etc/SQLHOSTS.$instance $INFORMIXSQLHOSTS 

#Verify that the raw devices or files of storage spaces are available
#IDS needs chunk files before restore
ids.create.chunk $instance

# Just follow the prompts for mounting restore tapes.
[[ $bkupdev = /dev/rmt* ]] && util.tape $bkupdev load

ontape -r -t $bkupdev |tee -a $LOGFILE
[[ $? -ne 0 ]] && {
  echo "$instance Database Restore Failed" >> $ERRFILE
  exit 2
  }

onmode -m >> $logFile
[[ $? -ne 0 ]] && {
  echo "$instance multi-user mode Failed" >> $ERRFILE
  exit 2
  }

# A message informs you when the restore is complete.
echo "Restore completed successfully, please check the mail ...\n"
mail -s "Informix $instance Database restore successful (`hostname`) @ `date`"\
        $SYSADMEMAIL <$LOGFILE

#umount tape in TapeDrive
[[ $bkupdev = /dev/rmt* ]] && util.tape $bkupdev offline

exit 0 

