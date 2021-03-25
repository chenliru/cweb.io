#######################################################################
# SHELL SCRIPTS TOOLS LIBRARY
#----------------------------------------------------------------------
# 
# Author : Liru Chen
# Licensed Materials - Property of LIRU; All Rights Reserved 2015-2019
#######################################################################
set -x			#display each line as it actually executes

#Mail address
mail_alert="lchen@livingstonintl.com"

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

snmon () {
	date_yesterday=$(TZ=EDT+24EDT date +%y%m%d)
	nmon_report_dir=/$1/$(hostname)/nmon_script/
	
	remotehost='10.253.131.47'
	username='lii01\\aixperf'
	password='AixFTP1224'
	localdir=${nmon_report_dir}
	remotedir=$(hostname)
	
	cd ${nmon_report_dir}

	nmon_reports=$(find . \( -name "*_$date_yesterday*.nmon" -o -name "*_$date_yesterday*.nmon.gz" \))

	[[ "${nmon_reports}" == "" ]] && {
		mail -s "$(hostname) NO_NMON_REPORT" "${mail_alert}" < /dev/null
		exit 1
	}

	for nmon_report in ${nmon_reports}
	do
		ftp_put ${remotehost} ${username} ${password} ${localdir} ${remotedir} ${nmon_report} ${nmon_report}
		mail -s "$(hostname) NMON REPORT SEND" "${mail_alert}" < /dev/null
	done

}

snmon $1

exit 0
