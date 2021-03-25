#!/usr/bin/ksh
########################################################
## Purpose: Used to stop INFORMIX services
########################################################

cd /home/informix

. ./ids115.env ipdb

ps -ef|grep -v "grep"|grep oninit

if [[ $? -eq 0 ]]
then 
 echo "Informix is running!" 
 onmode -ky

 if [[ $? -ne 0 ]]
 then
  mail -s "Informix Stop failed" aixsupport@livinstonintl.com  < /dev/null
  exit 1
 fi

fi

mail -s "Informix Stopped!" aixsupport@livingstonintl.com < /dev/null

exit 0

