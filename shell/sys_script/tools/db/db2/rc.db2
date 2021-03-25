#!/bin/ksh
################################################################################
#
# Name:         rc.db2 
#
# Reference:    n/a
#
# Description:  DB2 database start | stop | status maintenance
#
# Parameters:   rc.db2 {start|stop|status|restart} <db2_instance> 
# 
# Command:      
#
# Modification History:
# (Please modify it according to local db2 environment when implement on another system):
#
#               Date            Name            Description   
#               ------------------------------------------------------------
#               2012-12-24      Liru Chen       understanding DB2 processes
#
####################################################################################
set -v
set -x

if [[ $# -lt 2 ]]
then
  echo $"Usage: $0 {start|stop|status|restart} <db2_instance> <db_alias>"
  exit 1
fi

if [[ $USER != 'root' ]]
then
  echo "You should be root user"
  exit 2
fi

prog=$0
choice=$1
instance=$2
database=$3

logDate=`date +%Y%m%d%H%M`
logFile=db2rcLog$logDate

SLEEP_INTERVAL=2
MAX_SLEEP_TIME=30

if [ -f ../../toolsProfile ]; then
    . ../../toolsProfile
fi

cd $TOOLSDIR/log

msgLog()
{
  echo `date` "$1" >> $logFile
}

statusDB2()
{
  set -v
  set -x

echo "Show DB2 $instance Status..." >> $logFile
su - $instance << EOF
  . /home/$instance/sqllib/db2profile
  db2 connect to $database
  db2 list active databases | grep -i $database
EOF

  if [ $? -eq 0 ]; then
   g_status="running"
  else
   g_status="stopped"
  fi

  return $g_status
}

startDB2()
{
  set -v
  set -x
  echo "Start Database $instance Now" >> $logFile

# Starting all DB2 processes (Linux and UNIX)
su - $instance << EOF
  . /home/$instance/sqllib/db2profile

  db2start
  if [[ $? -gt 0 ]]; then
     print "ERROR when attempting to start $instance" >> $logFile
     exit -1
  fi

  db2 activate db $database
EOF

  statusDB2

  if [ $g_status != "running" ]; then
   msgLog "Error: DB2 $instance started failed..." >> $logFile
   exit 1
  fi

  return 0
}
  
stopDB2()
{
  set -v
  set -x
  echo "Stop Database $instance Now" >> $logFile

# Stopping all DB2 processes (Linux and UNIX)
su - $instance << EOF
  . /home/$instance/sqllib/db2profile
  db2 force applications all
  if [[ $? -gt 0 ]]; then
     print "ERROR when attempting to force all application: Exiting" >> $logFile
     exit -1
  fi

  db2stop force     # Stop DB2 database manager
  db2 terminate     # Stop all command line processor sessions,confirm instance is stopped
  db2licd -end      # run at each physical partition

  echo "# On AIX, Unload unused shared memory" >> $logFile
  [ `uname` = "AIX" ] && ( /usr/sbin/slibclean )

  echo "# Disable the fault monitor processes" >> $logFile
  db2fm -i $instance -D

  echo "# Prevent the instances from auto-start" >> $logFile
  db2fmcu | grep down
  if [[ $? -eq 1 ]]; then
    db2iauto -off $instance
    # db2iauto -on $instance
  fi

  echo "# Ensure all DB2 interprocess communications are cleaned" >> $logFile
  ipclean
EOF

  return 0
}

startDAS()
{
  # If the DB2 Administration Server (DAS) belongs to the DB2 copy that you are updating, stop the DAS: 
  set -v
  set -x

echo "Start DB2 Administration Server Now" >> $logFile
su - dasusr1 << EOF
  . /home/dasusr1/das/dasprofile
  db2admin start
EOF

  return 0
}

stopDAS()
{
  # If the DB2 Administration Server (DAS) belongs to the DB2 copy that you are updating, stop the DAS: 
  set -v
  set -x 

echo "Stop DB2 Administration Server Now" >> $logFile
su - dasusr1 << EOF
  . /home/dasusr1/das/dasprofile
  db2admin stop
EOF
  
  return 0
}

startAll() {
 echo "Starting DB2... "
 startDAS && msgLog "Message: DAS is started..." >> $logFile
 startDB2 && msgLog "Message: DB2 $instance started ..." >> $logFile
}

stopAll() {
 echo "Stopping DB2..."
 stopDB2 && msgLog "Message: DB2 $instance is stopped ..." >> $logFile
 stopDAS && msgLog "Message: DAS is stopped ..." >> $logFile
}

statusAll() {
 echo " Show DB2 status..."
 statusDB2 && msgLog "Message: DB2 $instance is $g_status" >> $logFile
}

restartAll() {
  stopAll
  startAll
}

# main #
 case $choice in
  start)
      startAll
      break
      ;;
  stop)
      stopAll
      break
      ;;
  restart)
      restartALl
      break
      ;;
  status)
      statusAll
      break
      ;;
    *)
      print " "
      print " - - - Invalid Entry - - -"
      print " "
      echo $"Usage: $0 {start|stop|status|restart} <db2_instance> <database>"
      exit 1
      ;;
  esac


exit $?


