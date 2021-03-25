#!/bin/ksh           
#
# Author:	Bob Chong
# Date:		Sept 18, 2002
# Purpose:	check TCL error
#
set -x

export INFORMIXSERVER=ipdb
#export INFORMIXDIR=/usr/apps/inf/ver731UD10
export INFORMIXDIR=/usr/apps/inf/ver115UC3
export PATH=$PATH:$INFORMIXDIR/bin:/usr/apps/ipg/ver001/util:/usr/apps/inf/bob/loglist

TclerrDir=/dmqjtmp/archiveTclerrLog

# get yesterday date
runyy=$(get_day 1 | cut -d - -f 1)
runmm=$(get_day 1 | cut -d - -f 2)
rundd=$(get_day 2 | cut -d - -f 3)
rundate=${runyy}${runmm}${rundd}

#create Target Directory;
mkdir ${TclerrDir}/${rundate}

date

/home/lchen/checkerr_report/checkerr10.ksh
/home/lchen/checkerr_report/checkerr21.ksh
/home/lchen/checkerr_report/checkerr31.ksh
/home/lchen/checkerr_report/checkerr32.ksh
/home/lchen/checkerr_report/checkerr34.ksh
/home/lchen/checkerr_report/checkerr41.ksh
#checkerr46.ksh
/home/lchen/checkerr_report/checkerr51.ksh
/home/lchen/checkerr_report/checkerr52.ksh
#checkerr61.ksh
/home/lchen/checkerr_report/checkerr70.ksh
/home/lchen/checkerr_report/checkerr71.ksh
/home/lchen/checkerr_report/checkerr81.ksh

#remove old logs older than 3 days;
# get yesterday date
oldyy=$(get_day 4 | cut -d - -f 1)
oldmm=$(get_day 4 | cut -d - -f 2)
olddd=$(get_day 4 | cut -d - -f 3)
olddate=${oldyy}${oldmm}${olddd}

#rm -r ${TclerrDir}/${olddate}

exit 0
