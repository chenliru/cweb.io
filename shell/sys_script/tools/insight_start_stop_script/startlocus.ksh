#!/usr/bin/ksh
########################################################
## Purpose: Used to start LOCUS services
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

if [[ $? -eq 0 ]]
then
  echo "Locus shutdown is not completed ...\n"
  mail -s "Locus still running!" aixsupport@livingstonintl.com < /dev/null
  exit 1
fi

echo "Locus services shutdown has completed.\n"
echo "... restart services in progress ...\n"
tmboot -y

echo "Verify locus services ....\n" 
count=`ps -ef|grep locus|grep -v "grep"|grep -v "loc_restart"|grep -v "cgi"|wc -l` 

if [[ $count -ne 16 ]]
then
  echo "We have difficulty to restart Locus services ...\n"
  mail -s "Error start Locus Services!" aixsupport@livingstonintl.com < /dev/null
  exit 1
fi

mail -s "Locus Services start `date`" aixsupport@livingstonintl.com < /dev/null

exit 0
