#!/bin/bash
#########################################################################
# SCRIPT             : active_dba_db_mon.bash                           #
#                                                                       #
# DESCRIPTION        : Shell script that performs active datbasae       #
#                      monitoring.                                      #
#                                                                       #
# INPUT FILES        : None                                             #
#                                                                       #
# OUTPUT FILES       : /kec1dump/datadump/db_mon/<db_name>/             #
#                      <db_name>.db_mon.YYYYMMDD_HHMMSS.log             #
#                                                                       #
# SETUP INSTRUCTIONS : The script reads the parameters defined under    #
#                      /home/oracle/script/db_monENV                    #
#                                                                       #
#########################################################################
# COMMAND LINE EXECUTION:                                               #
# Script_name     input parameters (flags)                              #
# ----------------------------------------                              #
# <script name>   parm1 parm2 etc showing optional parms in []          #
#                                                                       #
# parm record layout:                                                   #
# Parm 1 = Instance Name                                                #
#                                                                       #
# EXAMPLE: active_dba_db_mon.bash kec1proddb                            #
#########################################################################
#                                                                       #
# RESTART INSTRUCTIONS: If the script dies for any reason, kill any     #
#                       background processes (kill #9 ...) and re-run   #
#                       the script.                                     #
#                                                                       #
#########################################################################
# Modification Log:                                                     #
# Date        Name              Description                             #
#########################################################################
#                                                                       #
# Feb/24/17   Ramiz Sarah       Initial Creation                        #
# Mar/08/17   Ramiz Sarah       Revamped Alert Log Monitoring           #
#########################################################################
#

cd /home/oracle/script

. db_monENV             # Load db_mon parameters

DBNAME=$1

LOGDIR=$LOG_DIR/$DBNAME # Loaded from db_monENV
ERRMSG=$ERR_MSG         # Loaded from db_monENV

#EMAIL_LIST=rsarah@livingstonintl.com

# Check if DB Name is provided..

if [ -z "$1" ]
then
   echo "Error: No ORACLE_SID set or provided as an argument"
   exit 1
fi
#echo "ramiz says oracle_sid is ${ORACLE_SID}"
. $HOME/${DBNAME}.profile

#######################################################################
#  Check Listener's availability                                      #
#######################################################################

lsnr_proc="${ORA_LSNR_LST}"
for p in $lsnr_proc
do
   ps aux | grep $p > /dev/null

   if [ $? != 0 ]
   then
      echo "Alert" | mailx -s "Listener $p is Down on `hostname`" "$EMAIL_LIST"
   fi
done

#lsnr_cnt=`ps -ef | grep -E 'listener|LISTENER' | grep -v grep  | wc -l`
#if [ $lsnr_cnt -lt 6 ]
#then
#   # There are less than 6 listeners running.. one of them is down!!
#   echo "Alert" | mailx -s "Listener is Down on `hostname`" $EMAIL_LIST
#fi

#######################################################################
#  Check Instance availability                                        #
#######################################################################

inst_cnt=`ps -ef|grep ${DBNAME}|grep pmon|wc -l`;

if [ $inst_cnt -lt 1 ]; then
# No running instance..
   mailx -s "$DBNAME is down on `hostname`" "$EMAIL_LIST"
   exit 1
fi

#######################################################################
# Check if the Oracle instance is OPEN/accepting connections          #
#######################################################################

status=`sqlplus -s "/ as sysdba" <<EOF
set pagesize 0 feedback off verify off heading off echo off
select status from v\\$instance;
exit
EOF`

if [ $status != "OPEN" ]; then
   mailx -s "$DBNAME is NOT OPEN on `hostname`" "$EMAIL_LIST"
   exit 1
fi

#######################################################################
#  Check Alert Log Erros                                              #
#######################################################################

ALERTLOG_DIR=`sqlplus -s "/ as sysdba" << EOF
set pagesize 0 feedback off verify off heading off echo off
select value from v\\$parameter where name='background_dump_dest';
EOF`

filename=alert_${ORACLE_SID}.log
alrt=$ALERTLOG_DIR/$filename
last_cnt=${ORACLE_SID}.last.count
HOSTNAME=`hostname`

if [ -s "$LOGDIR/$last_cnt" ]; then
   frm=$(head -n 1 $LOGDIR/$last_cnt)
else
   frm=0
fi

# Get total number of lines in the alert log..
lst=$(wc -l $alrt | awk '{print $1}')

#
# Re-set the starting point back to 0 (begining of file) if the alert log has been recycled.
if [ "$frm" -gt "$lst" ]
then
   frm=0
fi

lns=$(awk -v a="$lst" -v b="$frm" 'BEGIN{print a-b+1}')

err=$(tail -$lns $alrt | egrep -i "${ERRMSG}" |tail -1|awk '{print $1}')

if [ $err ]; then
   tail -$lns $alrt | egrep -i "${ERRMSG}" > $LOGDIR/${ORACLE_SID}.mail
   cat $LOGDIR/${ORACLE_SID}.mail | mailx -s "Alert Log Errors Found for $ORACLE_SID on $HOSTNAME" "$EMAIL_LIST"
fi
#
# Update the lines count for subsequent runs;
echo $lst > $LOGDIR/$last_cnt

#######################################################################
#  Check Database Health                                              #
#######################################################################

# Remove the previous run temp file from the report directory (if exists)

if [ -f $LOGDIR/dbmon.log ]
then
   rm $LOGDIR/dbmon.log
fi

DB_MON=$DB_MON_USR
DB_MON_PWD=`cat ${ORACLE_SID}_encrypted_passwd|openssl enc -base64 -d`

sqlplus -s $DB_MON/\"$DB_MON_PWD\" <<EOF
whenever sqlerror exit sql.sqlcode;
set feedback off ;
@/home/oracle/sql/active_db_mon_main.sql
exit
EOF

# go to the report directory, if the file exists, rename and email

cd $LOGDIR

if [[ -s dbmon.log ]]
then
   log_file_name=${DBNAME}.db_mon.`date +"%Y%m%d_%H%M%S"`.log
   mv dbmon.log $LOGDIR/$log_file_name
#
   cat $LOGDIR/$log_file_name | mailx -s "Issues Found for $DBNAME" "$EMAIL_LIST"
fi

# Clean up the output directory; keep 7 days worth of data..
find $LOGDIR/ -name "*.db_mon._*.log" -mtime +7 -exec rm {} \;

exit
