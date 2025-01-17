#!/usr/bin/ksh

########################################################
## Purpose: Used to restart LOCUS services weekly;    ##
## Author:  Denny Guo                                 ##
## Date:    Auguest 1, 2007                           ##
########################################################


cd /usr/apps/ipg/ver001/srv/locus

. ./setenv.locus

echo "************    `date`  ***********\n"
ps -ef|grep -v "grep"|grep tcl|grep -v "com.ibm.lwi.LaunchLWI"
if [[ $? -eq 0 ]]
then 
  echo "Tcl is still running, it is unusual ...\n"
  echo "We should not restart LOCUS services ....\n"
  echo "Tcl should not be running at this time ... `date`" \
   | mail -s "Tcl is running unusual. Please verify!" aixsupport@livingstonintl.com
else
  echo "Tcl is not running .....\n"
  echo "Shutdown locus services in progress .....\n\n\n"
  tmshutdown -y
  sleep 180
  echo "\n\n==============================================================\n"
  echo "Verify whether locus service has been shutdown completely ....\n"
  ps -ef|grep locus|grep -v "grep"|grep -v "loc_restart"
  if [[ $? -eq 0 ]]
  then
    echo "Locus shutdown is not completed ...\n"
    echo "Quit restart procedure and notify Administrator ....\n"
    echo "==============================================================\n"
    echo "Please Call UNIX admin ASAP !!!" \
    | mail -s "Urgent : Error with shutdown Locus Services !" aixsupport@livingstonintl.com
    echo "Please Call UNIX admin ASAP !!!" \
 | mail -s "Urgent : Error with shutdown Locus Services !" computerops@livingstonintl.com
  else
    echo "Locus services shutdown has completed.\n"
    echo "We can restart all the services now.\n"
    echo "==============================================================\n\n"
    echo "************    `date`  ***********\n"
    echo "... no locus service is running ...\n"
    echo "... restart services in progress ...\n"
    tmboot -y
    echo "\n\n============================================================\n"
    echo "Verify locus services ....\n" 
    count=`ps -ef|grep locus|grep -v "grep"|grep -v "loc_restart"|wc -l` 

    if [[ $count -eq 16 ]]
    then
      echo "--- Locus services has been restarted without any issue. ---\n"
      echo "============================================================\n"
    else
      echo "We have difficulty to restart Locus services ...\n"
      echo "Quit restart procedure and notify Administrator ....\n"
      echo "============================================================\n"
      echo "Please Call UNIX admin ASAP !!!" \
    | mail -s "Urgent : Error with restart Locus Services !" aixsupport@livingstonintl.com
      echo "Please Call UNIX admin ASAP !!!" \
  | mail -s "Urgent : Error with restart Locus Services !" computerops@livingstonintl.com
    fi
  fi 
fi

mail -s "Locus Services Restart Report @ `date`" aixsupport@livingstonintl.com < restart.out
