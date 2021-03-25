#!/usr/bin/ksh

echo  
date

PATH=/usr/java6/jre/bin:$PATH
export PATH

echo "Change to working directory ...... \n"

cd /insight/local/scripts/iccdataupload

echo "Start ICCDataUpload ....\n"

#java -version

CLASSPATH=$CLASSPATH:.:/insight/local/scripts/iccdataupload/lib/ifxjdbc.jar:

export CLASSPATH


#nohup java ICCDataUpload >> ICCDataUpload.log &

java ICCDataUpload > unhandled_excps.out

#sleep 5

#PID=`ps -ef | grep "java ICCDataUpload" | grep -v "grep" | awk '{print $2}'`

#if [ $? -eq 1 ]

#then

#    echo "\n ** ERROR: the ICCDataUpload is NOT been started ! **\n"

#else

#    echo "ICCDataUpload  has been started successfully  ....\n"
#    mail -s "ICCDataUpload has been completed successfully" lchen@livingstonintl.com < /dev/null
#fi

cd /insight/local/scripts/iccdataupload/archive
alias rm='rm'

find . -mtime +3 -type d -exec rm -r {} \;

find /insight/local/scripts/iccdataupload/ -name "*log*.txt" -mtime +3 -exec rm {} \;
