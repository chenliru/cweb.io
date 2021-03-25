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
aixMail="lchen@livingstonintl.com"
pconMail="EKotsalainen@livingstonintl.com MStruys@livingstonintl.com lchen@livingstonintl.com"

wrkDir=/archbkup
tmpDir=$wrkDir/tmp

tmpFile=$tmpDir/$(basename $1)
tmpLoad=$tmpFile.load

outDate=$(date +%Y%m%d%H%M)

#create and/or empty working files
for tmpfiles in $tmpFile.b3iidNew $tmpFile.exclude $tmpFile.pconMail.load; do : > $tmpfiles; done

#working on informix DB now
. /home/informix/ids115.env ipdb

cat $1 | while read wip
do
	liibrno=${wip:0:3}
	liireno=${wip:3:8}

	b3iidNew=$(echo "
	select b3iid from b3 
	where liibrchno = $liibrno and liirefno = $liireno 
	" | dbaccess ip_0p | grep -v count | grep -v b3iid)
	   
	echo $b3iidNew >> $tmpFile.b3iidNew

	if [[ $b3iidNew = "" ]]
	then
		echo "$wip Missed" >> $tmpFile.pconMail.load
	fi

done

cat $tmpFile.b3iidNew | while read b3iidNew
do
	echo "
	UNLOAD TO "$tmpLoad.$b3iidNew" 
	SELECT b3iid, status 
	FROM status_history 
	WHERE b3iid = $b3iidNew
	" | dbaccess ip_0p
done

cat $tmpLoad.* >> $tmpFile.exclude; rm -f $tmpLoad.*

#bkup unloaded records from table status_history for each running of this script
cp $tmpFile.b3iidNew $tmpFile.b3iidNew.$outDate

#Get a list of loadable status_history_record

#Remove blank lines in New b3iid file
grep -v "^$" $tmpFile.b3iidNew > $tmpFile.include

grep -Ff $tmpFile.include $tmpFile.recordOldTime > $tmpFile.recordOldTime.tmp
grep -Fvf $tmpFile.exclude $tmpFile.recordOldTime.tmp > $tmpFile.record.final

recordnum=$(cat $tmpFile.record.final|wc -l)

echo " 
LOAD FROM $tmpFile.record.final
INSERT INTO status_history
" | dbaccess ip_0p 

cat $tmpFile.pconMail.load $tmpFile.record.final > $tmpFile.aixMail.load

mail -s "status_history load for $(basename $1) completed $recordnum records" "$aixMail" < $tmpFile.aixMail.load
mail -s "status_history load for $(basename $1) completed $recordnum records" "$pconMail" < $tmpFile.pconMail.load

