#!/bin/ksh93
#######################################################################
# SHELL SCRIPTS TOOLS LIBRARY
#----------------------------------------------------------------------
# 
# Author : Liru Chen
# Licensed Materials - Property of LIRU; All Rights Reserved 2015-2019
#######################################################################
#
# This script is modified for missed inremental data uploading
#
set -v 
set -x

ps -ef|grep -v grep|grep aws
[[ $? -eq 0 ]] && exit

MAILALERT="lchen@livingstonintl.com"

#AWS's Parameter 
#AWSDATE=$(date +%Y%m%d)
AWSDATE=20151111
AWSTIME=$(date +%Y%m%d%H%M%S)

AWSRUNDIR=/insight/local/scripts/VaxParser/tools

AWSINDIR=/dmqjtmp/rcp/stage/VaxParserOutput
AWSOUTBASE=/dmqjtmp/rcp/stage/AWSOutput
AWSOUTDIR=$AWSOUTBASE/${AWSDATE}
AWSTMPDIR=/recyclebox/AWS/tmp
AWSTMPOUTDIR=/recyclebox/AWS/${AWSDATE}
[[ ! -d $AWSINDIR ]] && mkdir -p $AWSINDIR
[[ ! -d $AWSOUTDIR ]] && mkdir -p $AWSOUTDIR
[[ ! -d $AWSTMPDIR ]] && mkdir -p $AWSTMPDIR
[[ ! -d $AWSTMPOUTDIR ]] && mkdir -p $AWSTMPOUTDIR

AWSREMOTE="ingest@a0almcdhcan01.dev.liiaws.net"
AWSREMOTEDATA="/opt/ingest/informix/data/${AWSDATE}"
AWSREMOTEKEY="/opt/ingest/informix/key/${AWSDATE}"
AWSREMOTEVAX="/opt/ingest/informix/locusvax/${AWSDATE}"
# AWSREMOTE="lchen@ifx01"
# AWSREMOTEDATA="/home/lchen/opt/ingest/informix/data/${AWSDATE}"
# AWSREMOTEKEY="/home/lchen/opt/ingest/informix/key/${AWSDATE}"
# AWSREMOTEVAX="/home/lchen/opt/ingest/informix/locusvax/${AWSDATE}"

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

#clear running directory

cd $AWSTMPDIR
rm -f $AWSTMPDIR/*

cd $AWSINDIR
rm -f $AWSINDIR/*.txt

cd $AWSINDIR/keydone
rm -f $AWSINDIR/keydone/*.txt

cd $AWSOUTDIR
rm -f $AWSOUTDIR/*

#Prepare/Copy Claudio's java ICCDATAUPLOAD key files
#ls *${AWSDATE}*.txt |
touch  $AWSOUTBASE/iccdatauploaddone.$AWSDATE
find $ICCDATAUPLOADOUTDIR -name "*${AWSDATE}*.txt" -amin +15 -print > $AWSOUTBASE/iccdatauploadcurrent.$AWSDATE
grep -vf $AWSOUTBASE/iccdatauploaddone.$AWSDATE $AWSOUTBASE/iccdatauploadcurrent.$AWSDATE|
while read name
do
	cp -p $name $VAXPARSEROUTDIR
done
cp $AWSOUTBASE/iccdatauploaddone.$AWSDATE $AWSOUTBASE/iccdatauploaddonelast.$AWSDATE
cp $AWSOUTBASE/iccdatauploadcurrent.$AWSDATE $AWSOUTBASE/iccdatauploaddone.$AWSDATE

#Prepare/Copy ICCBILLINGUPLOAD keys
#ls *${AWSDATE}*.txt |
touch  $AWSOUTBASE/iccbillinguploaddone.$AWSDATE
find $ICCBILLINGUPLOADOUTDIR -name "*${AWSDATE}*.txt" -amin +15 -print > $AWSOUTBASE/iccbillinguploadcurrent.$AWSDATE
grep -vf $AWSOUTBASE/iccbillinguploaddone.$AWSDATE $AWSOUTBASE/iccbillinguploadcurrent.$AWSDATE|
while read name
do
	cp -p $name $VAXPARSEROUTDIR
done
cp $AWSOUTBASE/iccbillinguploaddone.$AWSDATE $AWSOUTBASE/iccbillinguploaddonelast.$AWSDATE
cp $AWSOUTBASE/iccbillinguploadcurrent.$AWSDATE $AWSOUTBASE/iccbillinguploaddone.$AWSDATE

#Start generate incremental data and send to AWS
cd $AWSRUNDIR
./shlib aws 1>$AWSTMPDIR/MISSED$AWSTIME.out 2>&1

# #find SQL which returns no row
# cd $AWSRUNDIR
# ./shlib awsnorowfound

cd $AWSTMPDIR
cp $AWSTMPDIR/*.sql $AWSTMPOUTDIR
cp $AWSTMPDIR/MISSED$AWSTIME.out $AWSTMPOUTDIR
cp $AWSTMPDIR/*.error $AWSTMPOUTDIR
rm -f $AWSTMPDIR/*.tmp
rm -f $AWSTMPDIR/*.tmp1
rm -f $AWSTMPDIR/*.tmp2

cd $AWSINDIR/keydone
cp $AWSINDIR/keydone/*.txt $AWSTMPOUTDIR

ssh -i $AWSPRIVATEKY $AWSREMOTE \
"[[ ! -d $AWSREMOTEDATA ]] && mkdir -p $AWSREMOTEDATA"

ssh -i $AWSPRIVATEKY $AWSREMOTE \
"[[ ! -d $$AWSREMOTEKEY ]] && mkdir -p $AWSREMOTEKEY"

ssh -i $AWSPRIVATEKY $AWSREMOTE \
"[[ ! -d $AWSREMOTEVAX ]] && mkdir -p $AWSREMOTEVAX"

cd $AWSOUTDIR
scp -i $AWSPRIVATEKY $AWSOUTDIR/* $AWSREMOTE:$AWSREMOTEDATA
[[ $? -ne 0 ]] && {
mail -s "AWS incremental data upload failed" "$MAILALERT" < /dev/null
exit 1
}

$AWSOUTBASE/token.sh

scp -i $AWSPRIVATEKY $AWSOUTDIR/*.token $AWSREMOTE:$AWSREMOTEDATA
[[ $? -eq 0 ]] && {
mail -s "AWS incremental data upload completed" "$MAILALERT" < /dev/null
}

cd $AWSTMPOUTDIR
scp -i $AWSPRIVATEKY $AWSTMPOUTDIR/*.sql $AWSREMOTE:$AWSREMOTEKEY
[[ $? -eq 0 ]] && rm -f $AWSTMPOUTDIR/*.sql

scp -i $AWSPRIVATEKY $AWSTMPOUTDIR/*.txt $AWSREMOTE:$AWSREMOTEKEY
[[ $? -eq 0 ]] && rm -f $AWSTMPOUTDIR/*.txt

find $AWSTMPOUTDIR -name "*.error" -size +0 -print|
while read errorfile
do
mail -s "Failed key of $errorfile" "$MAILALERT" < $errorfile

scp -i $AWSPRIVATEKY $errorfile $AWSREMOTE:$AWSREMOTEKEY
[[ $? -eq 0 ]] && rm -f $errorfile
done

scp -i $AWSPRIVATEKY $AWSTMPOUTDIR/MISSED$AWSTIME.out $AWSREMOTE:$AWSREMOTEKEY
[[ $? -eq 0 ]] && {
grep -i error $AWSTMPOUTDIR/MISSED$AWSTIME.out
[[ $? -eq 0 ]] && mail -s "Errors in SQL MISSED$AWSTIME.out" "$MAILALERT" < /dev/null
rm -f $AWSTMPOUTDIR/MISSED$AWSTIME.out
}

exit 0
