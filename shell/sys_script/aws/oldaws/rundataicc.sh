#!/bin/ksh93
#######################################################################
# Uploading  ICC data files to AWS
#----------------------------------------------------------------------
# 
# Author : Claudio
# Licensed Materials - Property of Livingston
#######################################################################
set -v 
set -x

MAILALERT="lchen@livingstonintl.com"

#AWS's Parameter 
AWSDATE=$(date +%Y%m%d)
AWSTIME=$(date +%Y%m%d%H%M%S)

AWSRUNDIR=/insight/local/scripts/VaxParser/tools

AWSINDIR=/dmqjtmp/rcp/stage/VaxParserOutput
AWSOUTBASE=/dmqjtmp/rcp/stage/AWSOutput
AWSOUTDIR=$AWSOUTBASE/output

AWSTMPDIR=/recyclebox/AWS/tmp
AWSFAILDIR=/recyclebox/AWS/uploadfail/${AWSDATE}
AWSERRDIR=/recyclebox/AWS/parsererror/${AWSDATE}
[[ ! -d $AWSINDIR ]] && mkdir -p $AWSINDIR
[[ ! -d $AWSOUTDIR ]] && mkdir -p $AWSOUTDIR
[[ ! -d $AWSTMPDIR ]] && mkdir -p $AWSTMPDIR

AWSREMOTE="ingest@a0almcdhcan01.dev.liiaws.net"
AWSREMOTEDATA="/opt/ingest/informix/data/${AWSDATE}"
AWSREMOTEKEY="/opt/ingest/informix/key/${AWSDATE}"
AWSREMOTEVAX="/opt/ingest/informix/locusvax/${AWSDATE}"

#VaxParser's Parameter
VAXDIR=/dmqjtmp/rcp/done
VAXPARSERINDIR=/dmqjtmp/vaxparser
VAXPARSERPROCESSEDDIR=/dmqjtmp/vaxparserprocessed
VAXPARSEROUTDIR=$AWSINDIR
VAXPARSERRUNDIR=/insight/local/scripts/VaxParser

ICCDATAUPLOADOUTDIR=/dmqjtmp/rcp/stage/iccdatauploadOutput
ICCBILLINGUPLOADOUTDIR=/dmqjtmp/rcp/stage/ICCBillingUploadOutput

AWSPRIVATEKY=$AWSRUNDIR/.ssh/Privatekey

export AWSINDIR AWSOUTDIR AWSRUNDIR AWSTMPDIR 
export VAXPARSERINDIR VAXPARSERPROCESSEDDIR VAXPARSEROUTDIR VAXPARSERRUNDIR
export ICCDATAUPLOADOUTDIR ICCBILLINGUPLOADOUTDIR
export AWSREMOTE AWSREMOTEDATA AWSREMOTEKEY AWSREMOTEVAX AWSPRIVATEKY

#check token
[[ -e ${AWSRUNDIR}/run.token ]] && exit 1
touch ${AWSRUNDIR}/run.token

#check directory environment are all cleaned
cd $AWSTMPDIR
clearawstmpdir=$(ls $AWSTMPDIR|wc -l)
[[ $clearawstmpdir -ne 0 ]] && {
	mail -s " $AWSTMPDIR DIRECTORY NOT EMPTY" "$MAILALERT" < /dev/null
	
	rm -f ${AWSRUNDIR}/run.token
	exit 3
}

cd $AWSINDIR
clearawsindir=$(ls $AWSINDIR|wc -l)
[[ $clearawsindir -ne 1 ]] && {
	mail -s " $AWSINDIR DIRECTORY NOT EMPTY" "$MAILALERT" < /dev/null
	
	rm -f ${AWSRUNDIR}/run.token
	exit 3
}

cd $AWSINDIR/keydone
clearawsinkeydonedir=$(ls $AWSINDIR/keydone|wc -l)
[[ $clearawsinkeydonedir -ne 0 ]] && {
	mail -s " $AWSINDIR/keydone DIRECTORY NOT EMPTY" "$MAILALERT" < /dev/null
	
	rm -f ${AWSRUNDIR}/run.token
	exit 3
}

cd $AWSOUTDIR
clearawsoutdir=$(ls $AWSOUTDIR|wc -l)
[[ $clearawsoutdir -ne 0 ]] && {
	mail -s " $AWSOUTDIR DIRECTORY NOT EMPTY" "$MAILALERT" < /dev/null
	
	rm -f ${AWSRUNDIR}/run.token
	exit 3
}


#Prepare/Copy Claudio's java ICCDATAUPLOAD key files
#ls *${AWSDATE}*.txt |
touch  $AWSOUTBASE/iccdatauploaddone.$AWSDATE
find $ICCDATAUPLOADOUTDIR -name "*${AWSDATE}*.txt" -amin +10 -print > $AWSOUTBASE/iccdatauploadcurrent.$AWSDATE


#Prepare/Copy ICCBILLINGUPLOAD keys
#ls *${AWSDATE}*.txt |
touch  $AWSOUTBASE/iccbillinguploaddone.$AWSDATE
find $ICCBILLINGUPLOADOUTDIR -name "*${AWSDATE}*.txt" -amin +10 -print > $AWSOUTBASE/iccbillinguploadcurrent.$AWSDATE

[[ ! -s $AWSOUTBASE/iccdatauploadcurrent.$AWSDATE && ! -s $AWSOUTBASE/iccbillinguploadcurrent.$AWSDATE ]] && {
	mail -s " EMPTY ICC DATA DIRECTORY" "$MAILALERT" < /dev/null
	
	rm -f ${AWSRUNDIR}/run.token
	exit 3
}

grep -vf $AWSOUTBASE/iccdatauploaddone.$AWSDATE $AWSOUTBASE/iccdatauploadcurrent.$AWSDATE|
while read name
do
	cp -p $name $VAXPARSEROUTDIR
done
cp $AWSOUTBASE/iccdatauploaddone.$AWSDATE $AWSOUTBASE/iccdatauploaddone.$AWSTIME
cp $AWSOUTBASE/iccdatauploadcurrent.$AWSDATE $AWSOUTBASE/iccdatauploaddone.$AWSDATE

diff $AWSOUTBASE/iccdatauploaddone.$AWSDATE $AWSOUTBASE/iccdatauploaddone.$AWSTIME
rc_iccupload=$?


grep -vf $AWSOUTBASE/iccbillinguploaddone.$AWSDATE $AWSOUTBASE/iccbillinguploadcurrent.$AWSDATE|
while read name
do
	cp -p $name $VAXPARSEROUTDIR
done
cp $AWSOUTBASE/iccbillinguploaddone.$AWSDATE $AWSOUTBASE/iccbillinguploaddone.$AWSTIME
cp $AWSOUTBASE/iccbillinguploadcurrent.$AWSDATE $AWSOUTBASE/iccbillinguploaddone.$AWSDATE

diff $AWSOUTBASE/iccbillinguploaddone.$AWSDATE $AWSOUTBASE/iccbillinguploaddone.$AWSTIME
rc_iccbillingupload=$?

[[ ${rc_iccupload} -eq 0 && ${rc_iccbillingupload} -eq 0 ]] && {
	mail -s " No New ICCDATA FILES" "$MAILALERT" < /dev/null
	
	rm -f ${AWSRUNDIR}/run.token
	exit 4
}

#Start generate incremental data and send to AWS
cd $AWSRUNDIR
./aws.sh 1>$AWSTMPDIR/MISSED$AWSTIME.out 2>&1

#Setup DIRECTORY on AWS side
ssh -i $AWSPRIVATEKY $AWSREMOTE \
"[[ ! -d $AWSREMOTEDATA ]] && mkdir -p $AWSREMOTEDATA"

ssh -i $AWSPRIVATEKY $AWSREMOTE \
"[[ ! -d $$AWSREMOTEKEY ]] && mkdir -p $AWSREMOTEKEY"

ssh -i $AWSPRIVATEKY $AWSREMOTE \
"[[ ! -d $AWSREMOTEVAX ]] && mkdir -p $AWSREMOTEVAX"

#Start transfer data files and data token files from $AWSOUTDIR to AWS
cd $AWSOUTDIR
scp -i $AWSPRIVATEKY $AWSOUTDIR/* $AWSREMOTE:$AWSREMOTEDATA
if [[ $? -ne 0 ]]
then
	mail -s "ICC incremental data upload failed" "$MAILALERT" < /dev/null

	[[ ! -d $AWSFAILDIR ]] && mkdir -p $AWSFAILDIR
	cp $AWSOUTDIR/* $AWSFAILDIR
	mail -s "ICC upload failed incremental data copied to $AWSFAILDIR" "$MAILALERT" < /dev/null

else
	mail -s "ICC incremental data upload completed" "$MAILALERT" < /dev/null
fi

$VAXPARSERRUNDIR/datatoken.sh

scp -i $AWSPRIVATEKY $AWSOUTDIR/*.token $AWSREMOTE:$AWSREMOTEDATA
if [[ $? -ne 0 ]]
then

	mail -s "ICC incremental data token upload failed" "$MAILALERT" < /dev/null

	[[ ! -d $AWSFAILDIR ]] && mkdir -p $AWSFAILDIR
	cp $AWSOUTDIR/*.token $AWSFAILDIR
	mail -s "ICC upload failed incremental data token copied to $AWSFAILDIR" "$MAILALERT" < /dev/null

else
	mail -s "ICC incremental data token upload completed" "$MAILALERT" < /dev/null	
fi

#backup all logs, sql files, key files if errors during query informix db
cd $AWSTMPDIR
grep -i error $AWSTMPDIR/MISSED$AWSTIME.out
[[ $? -eq 0 ]] && {
	mail -s "VAX Errors in SQL MISSED$AWSTIME.out" "$MAILALERT" < /dev/null
	[[ ! -d $AWSERRDIR ]] && mkdir -p $AWSERRDIR
	cp $AWSTMPDIR/MISSED$AWSTIME.out $AWSERRDIR
	cp $AWSTMPDIR/*.sql $AWSERRDIR
	cp $AWSINDIR/keydone/*.txt $AWSERRDIR
}

find $AWSTMPDIR -name "*.error" -size +0 -print|
while read errorfile
do
	mail -s "ICC Failed key of $errorfile" "$MAILALERT" < $errorfile
	[[ ! -d $AWSFAILDIR ]] && mkdir -p $AWSFAILDIR
	cp $errorfile $AWSFAILDIR
done

#then, Clean $AWSTMPDIR
cd $AWSTMPDIR

rm -f $AWSTMPDIR/*.tmp
rm -f $AWSTMPDIR/*.tmp1
rm -f $AWSTMPDIR/*.tmp2

rm -f $AWSTMPDIR/*.dbacces
rm -f $AWSTMPDIR/*.vax4sql
rm -f $AWSTMPDIR/*.unload

rm -f $AWSTMPDIR/MISSED$AWSTIME.out
rm -f $AWSTMPDIR/*.sql
rm -f $AWSTMPDIR/*.error

#and, Clean $AWSOUTDIR
cd $AWSOUTDIR
rm -f $AWSOUTDIR/*.token
rm -f $AWSOUTDIR/*.${AWSDATE}??????

#Start transfer key files and key token files from $AWSINDIR/keydone to AWS
cd $AWSINDIR/keydone

scp -i $AWSPRIVATEKY $AWSINDIR/keydone/*.txt $AWSREMOTE:$AWSREMOTEKEY
if [[ $? -ne 0 ]]
then
	mail -s "ICC incremental Key files upload failed" "$MAILALERT" < /dev/null
	
	[[ ! -d $AWSFAILDIR ]] && mkdir -p $AWSFAILDIR
	cp $AWSINDIR/keydone/*.txt $AWSFAILDIR
	mail -s "ICC upload failed incremental keys copied to $AWSFAILDIR" "$MAILALERT" < /dev/null
	
else
	mail -s "ICC incremental Key files upload completed" "$MAILALERT" < /dev/null
fi

$VAXPARSERRUNDIR/datatoken.sh

scp -i $AWSPRIVATEKY $AWSINDIR/keydone/*.txt.token $AWSREMOTE:$AWSREMOTEKEY
if [[ $? -ne 0 ]]
then
	mail -s "ICC incremental Key files token upload failed" "$MAILALERT" < /dev/null

	[[ ! -d $AWSFAILDIR ]] && mkdir -p $AWSFAILDIR
	cp $AWSINDIR/keydone/*.txt.token $AWSFAILDIR
	mail -s "VAX upload failed incremental keys token copied to $AWSFAILDIR" "$MAILALERT" < /dev/null

else
	mail -s "ICC incremental Key files token upload completed" "$MAILALERT" < /dev/null
fi

#then, clean up $AWSINDIR/keydone
cd $AWSINDIR/keydone
rm -f $AWSINDIR/keydone/*.txt
rm -f $AWSINDIR/keydone/*.txt.token


#release process token lock
rm -f ${AWSRUNDIR}/run.token

exit 0
