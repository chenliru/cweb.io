#!/bin/ksh           
#
# Author:	Bob Chong
# Date:		Sept 18, 2002
# Purpose:	check Q21 error
#
set -x

export INFORMIXSERVER=ipdb
#export INFORMIXDIR=/usr/apps/inf/ver731UD10
export INFORMIXDIR=/usr/apps/inf/ver115UC3
export PATH=$PATH:$INFORMIXDIR/bin:/usr/apps/ipg/ver001/util:/usr/apps/inf/bob/loglist
export TERM=vt100
infileDir=/usr/apps/dmq/beta/LOGS/LOGS.1
TclerrDir=/dmqjtmp/archiveTclerrLog

# get yesterday date
runyy=$(get_day 1 | cut -d - -f 1)
runmm=$(get_day 1 | cut -d - -f 2)
rundd=$(get_day 2 | cut -d - -f 3)
rundate=${runyy}${runmm}${rundd}

#Target Directory;
LogDir=${TclerrDir}/${rundate}


# run the report
#cd /usr/apps/inf/bob/loglist
cd ${LogDir}
loglist $infileDir/ierr021.$rundate > ${rundate}021.xls
cut -c 9-63,71-83,96-158,192-194 ${rundate}021.xls > ${rundate}021.out

out21=${rundate}021.out
/usr/bin/rcp ${LogDir}/$out21 "informix@bellat:$out21"

exit 0
