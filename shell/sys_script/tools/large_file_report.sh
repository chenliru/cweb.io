#!/bin/ksh93
###########################################################################
# Program : large_file
# Purpose : find large files on AIX and Linux Server 
#           
# Usage	: $large_file_report [file_size]
# Author	: Boyczuk, Byron ; Chen, Liru
###########################################################################
#set -v
#set -x

#Mail address
mail_alert="lchen@livingstonintl.com"

work_dir=$(dirname $0)
report=${work_dir}/large_file_report.txt

#########################################################################
# Program : ftp script from Unix/Linux to Windows FTP Server
# $1: remote host name
# $2: user name
# $3: password
# $4: file local directory
# $5: file remote directory
# $6: remote file name
# $7: local file name
#########################################################################
ftp_put () {
	ftp -vn << END_OF_PUT
	open $1
	quote user $2
	quote pass $3
	bin
	lcd $4
	cd $5
	put $6 $7
	bye
END_OF_PUT
}

send_report () {

	local_dir=$(dirname $1)
	local_name=$(basename $1)
	
	remote_dir=$(dirname $2)
	remote_name=$(basename $2)

	[[ ! -e $1 ]] && {
		mail -s "$(hostname) NO_LOCAL_FILE to send" "${mail_alert}" < /dev/null
		exit 1
	}

	cd ${local_dir}

	ftp_put ${remotehost} ${username} ${password} ${local_dir} ${remote_dir} ${local_name} ${remote_name}
	mail -s "$(hostname) Large file REPORT SEND" "${mail_alert}" < /dev/null


}

large_file_report () {
	typeset -E15 TOTAL_SIZE=0.0
	typeset -E15 F_SIZE=0.0
	typeset -E15 MONITOR_FILE_SIZE

	PLATFORM=$(uname)

	MONITOR_FILE_SIZE=${1-500}		#default 500M
	((MONITOR_FILE_SIZE=(MONITOR_FILE_SIZE*1024)*2))	#number of blocks (512 bytes per block)

	if [[ $PLATFORM = "AIX" ]]
	then
		mount_point_column=2
		fstype_monitor="grep jfs"
		output_item="f_perm f_num_link f_owner f_group F_SIZE f_modify_month f_modify_date f_modify_time f_name"
	fi

	if [[ $PLATFORM = "Linux" ]]
	then
		mount_point_column=3
		fstype_monitor="grep ext"
		output_item="f_perm f_num_link f_owner f_group F_SIZE f_modify_month f_modify_date f_modify_time f_name"
	fi

	printf "%-12s %-8s %18s %-50s\r\n"  Owner Size Last_Modify_Time Name

	mount|${fstype_monitor}|awk '{print $'${mount_point_column}'}'|
	while read mount_point
	do
		find ${mount_point} -xdev \
			-type f \
			-size +${MONITOR_FILE_SIZE} \
			-exec ls -la {} \; 2>/dev/null|
		while read ${output_item}
		do
			((F_SIZE = (F_SIZE/1024)/1024))
			((TOTAL_SIZE = TOTAL_SIZE + F_SIZE))
			
			printf "%-12s %8.2fM %4s %-3s %-8s %-50s\r\n"   \
			${f_owner} ${F_SIZE} ${f_modify_month} ${f_modify_date} ${f_modify_time} ${f_name}
		
		done
		
	done
			
	echo "\r\n"
	printf "HOST[$(hostname)] Total Large File Size:   %15.2fM\n" ${TOTAL_SIZE}
	echo "\r\n"

}

large_file_report $1 > $report

#setup remote host information
remotehost='10.253.131.47'
remotedir=LargeFileReport/$(hostname)

username='lii01\\aixperf'
password='AixFTP1224'

send_report $report ${remotedir}/$(hostname)_$(date +%Y%m%d)_large_file_report.txt

exit 0
