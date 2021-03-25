#!/usr/bin/ksh
########################################################
## Purpose: Used to start INFORMIX services
########################################################

cd /home/informix

. ./ids115.env ipdb

ps -ef|grep -v "grep"|grep oninit

if [[ $? -eq 0 ]]
then 
  mail -s "Informix still running!" aixsupport@livingstonintl.com < /dev/null
  exit 0
fi

oninit

if [[ $? -ne 0 ]]
then
   echo "INFORMIX Start is not completed ...\n"
   mail -s "Error start informix!" aixsupport@livingstonintl.com < /dev/null
   exit 1
fi

mail -s "Informix Start!" aixsupport@livingstonintl.com < /dev/null

exit 0

