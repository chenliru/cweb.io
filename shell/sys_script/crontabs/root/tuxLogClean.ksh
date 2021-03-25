#!/bin/ksh
###############################################################################
#
# Name:		tuxLogClean.ksh
#
# Reference:    n/a
#
# Description:  backup locus tuxedo instance ULOG file and achive  
#
# Parameters:   None
#
# Modification History:
#
# 		Date            Name          	Description  
#		-----------------------------------------------------------
#		2002-10-22	Bob Chong	Original 	
#		2006-08-01	Denny Guo	Modified 	
#
################################################################################
set -v
set -x

TuxDir=/usr/apps/ipg/ver001/srv
LocusInstance=$TuxDir/locus

clean(){
   set -x
   integer n=$2
   dir=$1
   ar=ULOGS
   Logs=ULOG.*
  
   cd $dir
   [ -L $ar ] || exit 1
   set `ls -t $Logs`
   shift
   [ $1 ] && mv $* $ar

   cd $ar
   set `ls -t $Logs`
   until (((n-=1)<0))
   do 
      [ $1 ] &&  shift
   done
   rm -f $*
   compress $Logs >/dev/null 2>&1
}

clean $LocusInstance 3

#
InsightDir=/usr/apps/ipg/ver001/srv/insight
BdsDir=/usr/apps/ipg/ver001/srv/bds/pgm/ip_0p

find $InsightDir -name "ULOG.*" -type f -mtime +4 -exec /usr/bin/rm -f {} \;
find $BdsDir -name "ULOG.*" -type f -mtime +4 -exec /usr/bin/rm -f {} \;

exit 0
