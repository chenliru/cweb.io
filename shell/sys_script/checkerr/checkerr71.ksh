#!/bin/ksh           
#
# Author:	Bob Chong
# Date:		Sept 18, 2002
# Purpose:	check Q71 error
#
set -x

export INFORMIXSERVER=ipdb
#export INFORMIXDIR=/usr/apps/inf/ver731UD10
export INFORMIXDIR=/usr/apps/inf/ver115UC3
export PATH=$PATH:$INFORMIXDIR/bin:/usr/apps/ipg/ver001/util:/usr/apps/inf/bob/loglist
export TERM=vt100
infileDir=/usr/apps/dmq/beta/LOGS/LOGS.1

# get yesterday date
runyy=$(get_day 1 | cut -d - -f 1)
runmm=$(get_day 1 | cut -d - -f 2)
rundd=$(get_day 2 | cut -d - -f 3)
rundate=${runyy}${runmm}${rundd}

#Target Directory;
TclerrDir=/dmqjtmp/archiveTclerrLog
LogDir=${TclerrDir}/${rundate}

# run the report
#cd /usr/apps/inf/bob/loglist
cd ${LogDir}
loglist $infileDir/ierr071.$rundate > ${rundate}071.xls
cut -c 10-63,73-81,82-84,96-109,119-128,192-200 ${rundate}071.xls > ${rundate}071.out

out71=$rundate"071.out"
/usr/bin/rcp ${LogDir}/$out71 "informix@bellat:$out71"

