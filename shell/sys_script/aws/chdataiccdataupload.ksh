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

cd /dmqjtmp/rcp/stage/iccdatauploadOutput

ls *20170705* | while read a 
do
	echo $a; name=${a//20170705/20170706}
	echo $name
	mv $a $name
	
done
