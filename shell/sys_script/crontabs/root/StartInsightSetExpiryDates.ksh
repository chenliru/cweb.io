#!/usr/bin/ksh

echo  
date

PATH=/usr/java6/jre/bin:$PATH
export PATH

echo "Change to working directory ...... \n"

cd /insight/local/scripts/ICCSetExpiryDates

echo "Start ICCSetExpiryDates ....\n"

java -version

CLASSPATH=$CLASSPATH:.:/insight/local/scripts/ICCSetExpiryDates/lib/ifxjdbc.jar:

export CLASSPATH


#nohup java ICCSetExpiryDates >> ICCSetExpiryDates.log &

java ICCSetExpiryDates > unhandled_excps.out

#sleep 5

#PID=`ps -ef | grep "java ICCSetExpiryDates" | grep -v "grep" | awk '{print $2}'`
#if [ $? -eq 1 ]
#then
#    echo "\n ** ERROR: the ICCSetExpiryDates is NOT been started ! **\n"
#else
#    echo "ICCSetExpiryDates  has been started successfully  ....\n"
#    mail -s "ICCSetExpiryDates has been completed successfully" lchen@livingstonintl.com < /dev/null
#fi

#Clean the old log file;
find /insight/local/scripts/ICCSetExpiryDates/ -name "*log*.txt" -mtime +3 -exec rm {} \;
