
export PATH=$PATH:/archbkup/bin

load_sh.ksh $1 > /archbkup/log/loadsh.log 2>&1 

grep "Error in load file line" /archbkup/log/loadsh.log

if [ $? = 0 ]
then
	mail -s "Status_history load with errors!" lchen < /dev/null
	exit 1
fi

exit 0

