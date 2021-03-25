#!/bin/ksh93
#######################################################################
# SHELL SCRIPTS TOOLS LIBRARY
#----------------------------------------------------------------------
# 
# Author : Liru Chen
# Licensed Materials - Property of LIRU; All Rights Reserved 2015-2019
#######################################################################
#
# This script is modified for failed inremental data uploading 
# yesterday(20151111), stop processes in root crontab, modify:
# 1. AWSDATE=20151111
# 2. AWSVAXDIR=/dmqjtmp/rcp/done.0
# 3. cd /dmqjtmp/rcp/stage/AWSOutput
#    cp vaxdonelast.20151111 vaxdone.20151111
#
#
set -v 
set -x

ps -ef|grep -v grep|grep aws
[[ $? -eq 0 ]] && exit

MAILALERT="lchen@livingstonintl.com"

#AWS's Parameter 
#AWSDATE=$(date +%Y%m%d)
AWSDATE=20151111
AWSVAXDIR=/dmqjtmp/rcp/done.0
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
#AWSREMOTE="lchen@ifx01"
# AWSREMOTEDATA="/home/lchen/opt/ingest/informix/data/${AWSDATE}"
# AWSREMOTEKEY="/home/lchen/opt/ingest/informix/key/${AWSDATE}"
# AWSREMOTEVAX="/home/lchen/opt/ingest/informix/locusvax/${AWSDATE}"

#VaxParser's Parameter
VAXDIR=$AWSVAXDIR
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

#Start parse VAX data file

#clear running directory
cd $VAXPARSERPROCESSEDDIR
rm -f $VAXPARSERPROCESSEDDIR/*.vax
rm -f $VAXPARSERPROCESSEDDIR/*.vaxtoken

cd $AWSTMPDIR
rm -f $AWSTMPDIR/*

cd $AWSINDIR
rm -f $AWSINDIR/*.txt

cd $AWSINDIR/keydone
rm -f $AWSINDIR/keydone/*.txt

rm -f $AWSOUTDIR/*

#Get Locus VAX data files, 
touch $AWSOUTBASE/vaxdone.$AWSDATE
find $VAXDIR -name *.vax -amin +10 -print > $AWSOUTBASE/vaxcurrent.$AWSDATE
grep -vf $AWSOUTBASE/vaxdone.$AWSDATE $AWSOUTBASE/vaxcurrent.$AWSDATE|
while read name
do
	cp $name $VAXPARSERINDIR
done
cp $AWSOUTBASE/vaxdone.$AWSDATE $AWSOUTBASE/vaxdonelast.$AWSDATE
cp $AWSOUTBASE/vaxcurrent.$AWSDATE $AWSOUTBASE/vaxdone.$AWSDATE

#Parse Locus VAX data file, generate Locus VAX data key files
cd $VAXPARSERRUNDIR
./token.sh
./awsparser.ksh

#Prepare/Copy Claudio's java ICCDATAUPLOAD key files


#Start generate incremental data and send to AWS
cd $AWSRUNDIR
./shlib aws 1>$AWSTMPDIR/MISSED$AWSTIME.out 2>&1

cd $AWSTMPDIR
cp $AWSTMPDIR/*.sql $AWSTMPOUTDIR
cp $AWSTMPDIR/MISSED$AWSTIME.out $AWSTMPOUTDIR
cp $AWSTMPDIR/*.error $AWSTMPOUTDIR
rm -f $AWSTMPDIR/*.tmp
rm -f $AWSTMPDIR/*.tmp1
rm -f $AWSTMPDIR/*.tmp2

#cd $AWSINDIR/keydone
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
