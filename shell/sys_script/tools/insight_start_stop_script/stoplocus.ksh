#!/usr/bin/ksh
########################################################
## Purpose: Used to stop LOCUS services 
## Author:  Liru 
########################################################

cd /usr/apps/ipg/ver001/srv/locus

. ./setenv.locus

ps -ef|grep -v "grep"|grep ./tcl

if [[ $? -eq 0 ]]
then 
  echo "Tcl is still running, it is unusual ...\n"
  mail -s "Tcl is running unusual!" aixsupport@livingstonintl.com < /dev/null
  exit 1
fi

echo "Verify whether locus service has been shutdown completely ....\n"
ps -ef|grep locus|grep -v "grep"|grep -v "loc_restart"|grep -v "cgi"

if [[ $? -ne 0 ]]
then
  mail -s "Locus already down!" aixsupport@livingstonintl.com </dev/null
  exit 0
fi

echo "Shutdown locus services in progress .....\n\n\n"
tmshutdown -y
sleep 180

mail -s "Locus Services Stopped" aixsupport@livingstonintl.com < /dev/null

exit 0
