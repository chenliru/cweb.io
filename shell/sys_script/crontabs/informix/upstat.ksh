#!/bin/ksh
#
# purpose: run update statistics medium
#
export INFORMIXDIR=/usr/apps/inf/ver115UC3
export INFORMIXSERVER=ipdb
export PATH=$INFORMIXDIR/bin:$PATH

SQLDIR=/usr/apps/inf/bob/upstat

echo "update statitics started" 

weekday=$(date +%w)

if [[ $weekday == 6 ]]
then
 echo "update statistics"|dbaccess ip_0p > $SQLDIR/upstat_all.out 2>&1
else 
 time dbaccess < $SQLDIR/tbls_med.sql > $SQLDIR/upstat_all.out 2>&1
 time dbaccess < $SQLDIR/tbls_high.sql >> $SQLDIR/upstat_all.out 2>&1
 time dbaccess < $SQLDIR/proc.sql >> $SQLDIR/upstat_all.out 2>&1
fi

#mail -s "Informix DB upstat done @ $(hostname)" aixsupport@livingstonintl.com < $SQLDIR/upstat_all.out
mail -s "Informix DB upstat done @ $(hostname)" lchen@livingstonintl.com < $SQLDIR/upstat_all.out

exit 0

