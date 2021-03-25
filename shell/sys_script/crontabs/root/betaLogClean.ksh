#!/bin/ksh
################################################################################
#
# Name:		betaLogClean.ksh
#
# Reference:    n/a 
#
# Description: 	backup ierr*, iaud*, dmqlog.* and archive to LOGS dir 
#
# Parameters:   None
#
# Modification History:
#
#		Date            Name          	Description  
#		----------------------------------------------------------
#		2002-10-22	Bob Chong	Original 
#
#################################################################################
set -v
set -x

Beta=/usr/apps/dmq/beta
BetaLogs=/dmqjtmp/archiveBetaLog/beta/LOGS

BIN=/insight/local/scripts
ARN=$BIN/arn.ksh

psCountEq(){
   set -x
   [ `ps -ef | egrep "$1" | wc -l` = $2 ]
}

IsReaderDown(){
   set -x
   psCountEq "[0-9] \./(tcl|cta)" 0
}

archiveLogList(){
   set -x
   RdDir=$1
   Vlogs="$RdDir/i???0??.????????"
   Dlogs="$RdDir/dmq???.???"
   Logs="$Vlogs $Dlogs"
   ArDir=$2
   n=3
   ([ -d $ArDir ] || [ -f $ArDir ]) && $ARN $ArDir $n
   (ls $Vlogs || ls $Dlogs) >/dev/null 2>&1 || return 0
   mkdir $ArDir && { mv $Logs $ArDir 2>/dev/null; $ARN $ArDir $n; }
}

archiveLog(){
   set -x
   archiveLogList $Beta  $BetaLogs || print "betaLogClean failed!"
}

IsReaderDown && { archiveLog; return 0; }

exit 0

