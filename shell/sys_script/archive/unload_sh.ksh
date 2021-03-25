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
aixMail="lchen@livingstonintl.com"
pconMail="EKotsalainen@livingstonintl.com MStruys@livingstonintl.com lchen@livingstonintl.com"

wrkDir=/archbkup
tmpDir=$wrkDir/tmp
tmpFile=$tmpDir/$(basename $1)

outDate=$(date +%Y%m%d%H%M)

export PATH=$PATH:$wrkDir/bin
datecalc.ksh -a `date "+%Y"` `date "+%m"` `date "+%d"` - 365 | read tmpYear tmpMonth tmpDay 

[[ $tmpMonth -lt 10 ]] && tmpMonth=0$tmpMonth

#working on informix DB now
. /home/informix/ids115.env ipdb

## First Part; Record all old b3iid related to WIP ##

#create and/or empty working files
for tmpfiles in $1.status_history.unload $tmpFile.b3iidOld $tmpFile.pconMail.unload; do : > $tmpfiles; done

cat $1 | while read wip
do
	liibrno=${wip:0:3}
	liireno=${wip:3:8}

	echo $liibrno
	echo $liireno

	b3iidOld=$(echo "
		select b3iid from b3 
		where liibrchno = $liibrno and liirefno = $liireno 
		" | dbaccess ip_0p | grep -v count | grep -v b3iid)
	echo $b3iidOld >> $tmpFile.b3iidOld

	if [[ $b3iidOld = "" ]]
	then
		echo "$wip Missed" >> $tmpFile.pconMail.unload
	fi

done 

## Second Part; Record old data for status_history ##
unloadTmp=$tmpFile.unload
unloadTmpTime=$tmpFile.unloadTime
cat /dev/null > $tmpFile.recordOld; cat /dev/null > $tmpFile.recordOldTime

cat $1 | while read wip
do
	liibrno=${wip:0:3}
	liireno=${wip:3:8}

	echo "
	UNLOAD TO "$unloadTmp.$liibrno.$liireno" 
	SELECT status_history.b3iid, status_history.status, 
		   status_history.statusdate FROM b3,status_history
	WHERE liibrchno = $liibrno
	 and  liirefno = $liireno
	 and  b3.b3iid = status_history.b3iid 
	" |	dbaccess ip_0p

	echo "
	UNLOAD TO "$unloadTmpTime.$liibrno.$liireno" 
	SELECT status_history.b3iid, status_history.status, 
		   status_history.statusdate FROM b3,status_history
	WHERE liibrchno = $liibrno 
	 and  liirefno = $liireno 
	 and  b3.b3iid = status_history.b3iid 
	 and  statusdate > '$tmpYear/$tmpMonth/%'
	" |	dbaccess ip_0p

done

cat $unloadTmp.* >> $tmpFile.recordOld; cat $unloadTmpTime.* >> $tmpFile.recordOldTime
rm -f $unloadTmpTime.*; rm -f $unloadTmp.*

## Third Part;  Clear old data for status_history ##

cat $tmpFile.b3iidOld | while read b3iid_delete
do

	echo " 
	DELETE FROM status_history 
	where  b3iid = $b3iid_delete
	" | dbaccess ip_0p

done

#bkup unloaded records from table status_history for each running of this script
cp $tmpFile.recordOld $tmpFile.recordOld.$outDate
cp $tmpFile.recordOldTime $tmpFile.recordOldTime.$outDate
cp $tmpFile.b3iidOld $tmpFile.b3iidOld.$outDate

cat $tmpFile.pconMail.unload $tmpFile.recordOld > $tmpFile.aixMail.unload

mail -s "status_history download for $(basename $1) completed (loading records)" "$aixMail" < $tmpFile.recordOldTime
 
mail -s "status_history download for $(basename $1) completed" "$aixMail" < $tmpFile.aixMail.unload 
mail -s "status_history download for $(basename $1) completed" "$pconMail" < $tmpFile.pconMail.unload


