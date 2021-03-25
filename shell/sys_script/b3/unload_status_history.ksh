
export PATH=$PATH:/archbkup/bin

unload_sh.ksh $1 > /archbkup/log/unloadsh.log 2>&1 

#grep Error /archbkup/etc/unloadsh.log
#if [ $? = 0 ]
	#then
	# mail -s "Status_history unload with errors!" lchen < /dev/null
	# exit 1
#fi

exit 0

