#!/bin/ksh
################################################################################
#
# Name:		betaLogClean.ksh
#
# Reference:    n/a 
#
# Description: 	Download related Logs and Archive to LOGS dir 
#
# Parameters:   None
#
# Modification History:
#
#		Date            Name          	Description  
#		----------------------------------------------------------
#		2007-04-17	Denny Guo	Original 
#
#################################################################################
set -v
set -x

Bds=/usr/apps/ipg/ver001/srv/bds/pgm/ip_0p
BdsLogs=/dmqjtmp/archiveBdsLog/bds/LOGS

BIN=/insight/local/scripts
ARN=$BIN/arn.ksh

archiveLogList(){
   set -x
   RdDir=$1
   B3EXlogs="$RdDir/B3EX_????????.log"
   B3RXlogs="$RdDir/B3RX_????????.log"
   B3PXlogs="$RdDir/B3PX_????????.log"
   TRFXlogs="$RdDir/TRFX_????????.log"
   AINXlogs="$RdDir/AINX_????????.log"
   QLISlogs="$RdDir/qlistener_????????.log"
   BDSlogs="$RdDir/bds_????????.log"
   XBATSlogs="$RdDir/xbats600_????????.log"
   Logs="$B3EXlogs $B3RXlogs $B3PXlogs $TRFXlogs \
         $AINXlogs $QLISlogs $BDSlogs $XBATSlogs"
   ArDir=$2
   n=3
   ([ -d $ArDir ] || [ -f $ArDir ]) && $ARN $ArDir $n
   mkdir $ArDir && { mv $Logs $ArDir 2>/dev/null; $ARN $ArDir $n; }
}

archiveLog(){
   set -x
   archiveLogList $Bds  $BdsLogs || print "betaLogClean failed!"
}

archiveLog

cat /dev/null > $Bds/encrypt.log

exit 0

