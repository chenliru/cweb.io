#!/bin/ksh           
#
# Author:	Bob Chong
# Date:		Sept 18, 2002
# Purpose:	check Q52 error
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
loglist $infileDir/ierr052.$rundate > ${rundate}052.xls
cut -c 9-63,71-83,96-158,192-194 ${rundate}052.xls > ${rundate}052.out

out52=$rundate"052.out"
/usr/bin/rcp ${LogDir}/$out52 "informix@bellat:$out52"

