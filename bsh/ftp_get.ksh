#!/bin/ksh93
#######################################################################################
#
#  Filename    : tableFTP.ksh
#
#  Author      : Liru Chen
#
#  Description : GET table data files using FTP
#
#  Date        : 2015-03-06
#                2015-03-13
#
########################################################################################
set -x
set -v

#hard-coded input parameters
userName='lchen'
passWord='admin12'
remoteServer='ifx01'

sourceDir='/usr/local/dbbkup/stage'
targetDir='/archbkup/dbbkup/stage'
mailList='lchen@livingstonintl.com'

#move file function
ftp_get () {
if [ $remoteServer == `hostname` ]
then
	cp -p $sourceDir/* $targetDir
else

ftp -vin << END_OF_FTP
	open $remoteServer
	user $userName $passWord
	lcd $sourceDir
	cd $targetDir
	bin
	prompt
	mget *
	bye
END_OF_FTP

fi
}

ftp_get

exit 0
