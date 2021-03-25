#!/usr/bin/ksh93
###########################################################################
#  load status_history related to WIPs file
#
#  Author : Liru Chen
#  Date: 2014-10-07
############################################################################
set -v
set -x

if [[ $# != 1 ]]
then
	echo $"Usage: $0 WIP_file"
	exit 1
fi

#Mail address
amail="lchen@livingstonintl.com"
pmail="EKotsalainen@livingstonintl.com MStruys@livingstonintl.com lchen@livingstonintl.com"

DATETIME=$(date +%Y%m%d%H%M)

#Working directories
BASE=/archbkup
BIN=$BASE/bin
TMP=$BASE/tmp
ETC=$BASE/etc
LOG=$BASE/log
[[ ! -d $LOG ]] && mkdir -p $LOG
[[ ! -d $TMP ]] && mkdir -p $TMP
[[ ! -d $ETC ]] && mkdir -p $ETC
[[ ! -d $BIN ]] && mkdir -p $BIN

PATH=$BASE/bin:$PATH;export PATH
DUPNAME=$TMP/$(basename $1)

#INFORMIX DYNAMIC SERVER
if [[ $(hostname) = "ifx01" ]]
then
	IDSENV="/home/informix/ids115.env"
	# IDSSERVER="ipdb"
	# IDSDB="ip_0p"
elif [[ $(hostname) = "ipdev" ]]
then 
	IDSENV="/login/infown/ids115.env"
	IDSSERVER="systestdb"
	IDSDB="ip_systest"
fi

#Informix DB running environments
. $IDSENV $IDSSERVER

fun_runsql () {
	if [[ -f $1 ]]
	then
		dbaccess $IDSDB $1
	else
		echo "$1" | dbaccess $IDSDB 
	fi
}

#create and/or empty working files
cat /dev/null > $DUPNAME.wipload.sql

cat $1 | while read wip
do
	liibrno=${wip:0:3}
	liireno=${wip:3:8}

	echo $liibrno
	echo $liireno
	
	echo "
	UNLOAD TO $DUPNAME.tmpwipload.$liibrno.$liireno
	SELECT $wip,b3iid from b3 
	WHERE liibrchno = $liibrno 
	  and liirefno = $liireno
	;
	" >> $DUPNAME.wipload.sql

done 

fun_runsql $DUPNAME.wipload.sql;cat $DUPNAME.tmpwipload.* > $DUPNAME.wipload;rm -f $DUPNAME.tmpwipload.* 
cut -f1 -d'|' $DUPNAME.wipload > $DUPNAME.wipload.exist
cut -f2 -d'|' $DUPNAME.wipload > $DUPNAME.b3iidload

echo "Below WIPs Missed" > $DUPNAME.pmail.load; grep -Fvf $DUPNAME.wipload.exist $1 >> $DUPNAME.pmail.load

cat $DUPNAME.b3iidload | while read b3iid_load
do
	echo "
	UNLOAD TO $DUPNAME.tmpb3iidload.$b3iid_load
	SELECT b3iid, status 
	FROM status_history 
	WHERE b3iid = $b3iid_load
	;
	" >>  $DUPNAME.b3iidload.sql
	
done

fun_runsql $DUPNAME.b3iidload.sql;cat $DUPNAME.tmpb3iidload.* > $DUPNAME.b3iidload.exclude;rm -f $DUPNAME.tmpb3iidload.*


#Get a list of loadable status_history_record

#Remove blank lines in New b3iid file
grep -v "^$" $DUPNAME.b3iidload > $DUPNAME.b3iidload.include

#The loading data set must include b3iid in b3, and cannot include same b3iid,status in status_history  
grep -Ff $DUPNAME.b3iidload.include $DUPNAME.record > $DUPNAME.record.tmp
grep -Fvf $DUPNAME.b3iidload.exclude $DUPNAME.record.tmp > $DUPNAME.record.final

recordnum=$(wc -l $DUPNAME.record.final)
recordsql="LOAD FROM $DUPNAME.record.final INSERT INTO status_history"

fun_runsql $recordsql

cat $DUPNAME.pmail.load $DUPNAME.record.final > $DUPNAME.amail.load

#bkup unloaded records from table status_history for each running of this script
cp $DUPNAME.b3iidload  $DUPNAME.b3iidload.$DATETIME
cp $DUPNAME.wipload.exist $DUPNAME.wipload.exist.$DATETIME

mail -s "status_history load for $(basename $1) completed $recordnum records" "$amail" < $DUPNAME.amail.load
mail -s "status_history load for $(basename $1) completed $recordnum records" "$pmail" < $DUPNAME.pmail.load

