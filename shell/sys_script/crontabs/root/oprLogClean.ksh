#!/bin/ksh
#########################################################################
#
# Name:		oprLogClean.ksh
#
# Reference:	n/a
#
# Description:	archive the data file
#		archive the token file
#		archive the token error file
#		archive the runner log file
#		archive the ipDog log file  
#
# Parameters:   None 
#
# Modification History:
#
#		Date            Name          	Description  
#		--------------------------------------------------------
#		2002-10-22	Bob Chong	Original
#
###########################################################################
set -v
set -x

BIN=/insight/local/scripts
ARN=$BIN/arn.ksh

RdrVaxFileArDir=/dmqjtmp/rcp/done
RdrVaxTokenArDir=/dmqjtmp/dmqvax/tokendone
RdrVaxTokenErrDir=/dmqjtmp/dmqvax/tokenerror

RunnerLog=/dmqjtmp/archiveRunnerLog/runner.log
RunnerOut=/dmqjtmp/archiveRunnerLog/runner.out

AlertDogLog=/dmqjtmp/archiveAdogLog/alertDog.log
AlertDogOut=/dmqjtmp/archiveAdogLog/alertDog.out

WatchDogLog=/dmqjtmp/archiveWdogLog/watchDog.log
WatchDogOut=/dmqjtmp/archiveWdogLog/watchDog.out

EmailDogLog=/dmqjtmp/archiveEdogLog/emailDog.log
EmailDogOut=/dmqjtmp/archiveEdogLog/emailDog.out

$ARN $RdrVaxFileArDir	3 && mkdir $RdrVaxFileArDir
$ARN $RdrVaxTokenArDir	3 && mkdir $RdrVaxTokenArDir
$ARN $RdrVaxTokenErrDir	3 && mkdir $RdrVaxTokenErrDir

$ARN $RunnerLog		3 && >$RunnerLog
$ARN $RunnerOut		3 && >$RunnerOut

$ARN $AlertDogLog	3 && >$AlertDogLog
$ARN $AlertDogOut	3 && >$AlertDogOut

$ARN $WatchDogLog	3 && >$WatchDogLog
$ARN $WatchDogOut	3 && >$WatchDogOut

$ARN $EmailDogLog	3 && >$EmailDogLog
$ARN $EmailDogOut	3 && >$EmailDogOut

#VaxDataDir=$DmqJtmp/vaxdata
#VaxTokenDir=$DmqJtmp/vaxtoken
#( cd $VaxDataDir; compress * >/dev/null 2>&1 )
#$ARN $VaxDataDir  3 && mkdir $VaxDataDir && chown dmqvax $VaxDataDir
#$ARN $VaxTokenDir 3 && mkdir $VaxTokenDir && chown dmqvax $VaxTokenDir

exit 0

