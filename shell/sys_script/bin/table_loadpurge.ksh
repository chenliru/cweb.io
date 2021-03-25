#!/bin/ksh93
#######################################################################################
#
#  Filename    : table_loadpurge.ksh
#
#  Author      : Liru Chen
#
#  Description : Clean record in child table which no reference key in parent table
#
#				 This tool is used when unloaded data files are so huge that you cannot
#				 use delete from child table<table1> 
#				 where keyfield NOT IN (select keyfield from parent table<table2>) 
#
#  Date        : 2015-03-06
#                2015-05-18
#				 2017-08-30
########################################################################################
set -x
set -v

BASE=/dbbkup
BIN=$BASE/bin
TMP=$BASE/tmp
ETC=$BASE/etc
LOG=$BASE/log

DATADIR=${TMP}/data
SQLDIR=${ETC}/sql

#INFORMIX DYNAMIC SERVER
if [[ $(hostname) = "ifx01" ]]
then
	IDSENV="/home/informix/ids115.env"
	IDSSERVER="ipdb"
	IDSDB="ip_0p"
elif [[ $(hostname) = "ipdev" ]]
then 
	IDSENV="/login/infown/ids115.env"
	IDSSERVER="systestdb"
	IDSDB="ip_systest"
fi
	
. $IDSENV $IDSSERVER

func_dbaccess () {
	if [[ -f $1 ]]
	then
		dbaccess $IDSDB $1
	else
		echo "$1" | dbaccess $IDSDB 
	fi
}


prtable=${1-${DATADIR}/b3_line.20150517}
chtable=${2-${DATADIR}/b3_recap_details.20150517}

missedkey=${DATADIR}/${prtable}.missedkey
missedsql=${DATADIR}/${prtable}.missedkey.sql
keyfiled=2

: > ${missedkey}
: > ${missedsql}

cut -f${keyfiled} -d "|" ${chtable} |
while read column
do
	grep "^${column}|" ${prtable}
	[[ $? -ne 0 ]] && echo ${column} >> ${missedkey}
done
 
cat ${missedkey} | while read column
do
	echo "
	DELETE FROM ${chtable}
	WHERE b3lineiid = ${column} 
	;"  >> ${missedsql} 
done

func_dbaccess ${missedsql}

exit 0