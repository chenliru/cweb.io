#!/usr/bin/ksh93
###########################################################################
#  Unload & Clear status_history related to WIPs file
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

## First Part; Record all old b3iid related to WIP ##

#create and/or empty working files
cat /dev/null > $DUPNAME.wipunload.sql

cat $1 | while read wip
do
	liibrno=${wip:0:3}
	liireno=${wip:3:8}

	echo $liibrno
	echo $liireno
	
	echo "
	UNLOAD TO $DUPNAME.tmpwipunload.$liibrno.$liireno
	SELECT $wip,b3iid
	FROM b3 
	WHERE liibrchno = $liibrno 
	  and liirefno = $liireno
	;
	" >> $DUPNAME.wipunload.sql

done 

fun_runsql $DUPNAME.wipunload.sql;cat $DUPNAME.tmpwipunload.* > $DUPNAME.wipunload;rm -f $DUPNAME.tmpwipunload.* 
cut -f1 -d'|' $DUPNAME.wipunload > $DUPNAME.wipunload.exist
cut -f2 -d'|' $DUPNAME.wipunload > $DUPNAME.b3iidunload

echo "Below WIPs Missed" > $DUPNAME.pmail.unload; grep -Fvf $DUPNAME.wipunload.exist $1 >> $DUPNAME.pmail.unload

## Second Part; Record old data for status_history ##
cat /dev/null > $DUPNAME.unloadall.sql; cat /dev/null > $DUPNAME.unload.sql

datecalc.ksh -a `date "+%Y"` `date "+%m"` `date "+%d"` - 365 | read Year Month Day 
[[ $Month -lt 10 ]] && Month=0$Month

cat $1 | while read wip
do
	liibrno=${wip:0:3}
	liireno=${wip:3:8}

	echo "
	UNLOAD TO $DUPNAME.tmpunloadall.$liibrno.$liireno
	SELECT status_history.b3iid,status_history.status,
		   status_history.statusdate 
	FROM b3,status_history
	WHERE liibrchno = $liibrno
	  and liirefno = $liireno
	  and b3.b3iid = status_history.b3iid 
	;
	" >> $DUPNAME.unloadall.sql

	echo "
	UNLOAD TO $DUPNAME.tmpunload.$liibrno.$liireno
	SELECT status_history.b3iid,status_history.status,
		   status_history.statusdate 
	FROM b3,status_history
	WHERE liibrchno = $liibrno 
	  and liirefno = $liireno 
	  and b3.b3iid = status_history.b3iid 
	  and statusdate > '$Year/$Month/%'
	;
	" >> $DUPNAME.unload.sql

done

fun_runsql $DUPNAME.unloadall.sql;cat $DUPNAME.tmpunloadall.* > $DUPNAME.recordall;rm -f $DUPNAME.tmpunloadall.*
fun_runsql $DUPNAME.unload.sql;cat $DUPNAME.tmpunload.* > $DUPNAME.record;rm -f $DUPNAME.tmpunload.*


## Third Part;  Clear old data for status_history ##
cat /dev/null > $DUPNAME.delete.sql
cat $DUPNAME.b3iidunload | while read b3iid_delete
do

	echo " 
	DELETE FROM status_history 
	WHERE b3iid = $b3iid_delete
	;
	" >> $DUPNAME.delete.sql

done

fun_runsql $DUPNAME.delete.sql

##bkup unloaded records from table status_history for each running of this script
cp $DUPNAME.recordall $DUPNAME.recordall.$DATETIME;cp $DUPNAME.recordall $1.status_history.unload
cp $DUPNAME.record $DUPNAME.record.$DATETIME
cp $DUPNAME.b3iidunload $DUPNAME.b3iidunload.$DATETIME
cp $DUPNAME.wipunload.exist $DUPNAME.wipunload.exist.$DATETIME

cat $DUPNAME.pmail.unload $DUPNAME.recordall > $DUPNAME.amail.unload

mail -s "status_history download for $(basename $1) completed (loading records)" "$amail" < $DUPNAME.record
 
mail -s "status_history download for $(basename $1) completed" "$amail" < $DUPNAME.amail.unload
mail -s "status_history download for $(basename $1) completed" "$pmail" < $DUPNAME.pmail.unload


