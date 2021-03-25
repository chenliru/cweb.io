#!/bin/ksh
##############################################################################
#
# Name:        watchDog.ksh
#
# Reference:   n/a
#
# Description: monitor the INSIGHT subsystems
#       
# Parameters:  None
#
# Modification History:
#
#   		Date       	Name		Description
#   		-------------------------------------------------------
#		2002-10-22	Bob Chong	Original
#		2006-07-26	Denny Guo	Modified
#
##############################################################################
set -v
set -x

# log and reference files
msgLog=/dmqjtmp/archiveWdogLog/watchDog.log
reFile=/dmqjtmp/archiveWdogLog/watchDog.ref

# email user list
#set -A AlertList bchong@livingstonintl.com \
#set -A AlertList aixsupport@livingstonintl.com \
#                 computerops@livingstonintl.com
set -A AlertList lchen@livingstonintl.com \
                 bchong@livingstonintl.com \
                 dguo@livingstonintl.com \
                 tward@livingstonintl.com \
                 computerops@livingstonintl.com

msgLog(){
  set -x
  print `date` "\n$1\n" >> $msgLog
}

msgAction(){
  set -x
  msg="URGENT: please call the IP Unix administrator immediately!"
  print "\n$msg\n"
}

msgAlert(){
  set -x
  #msgAction | mail -s "IFX01 Subsystem Error Message" ${AlertList[*]}
  #By DGuo 2006-07-26
  #mail -s "IFX01 Error,Please Call Unix Administrator ASAP!" ${AlertList[*]} < $msgLog
  mail -s "IFX01 Error, Please Call unix Administrator ASAP!" aixsupport@livingstonintl.com < $msgLog
  mail -s "IFX01 Error, Please Call unix Administrator ASAP!" computerops@livingstonintl.com < $msgLog
}

### check the environments and subsystems

#No need to check qme, the VPOM has been retired on 2011/04/06
qmeIsUp(){
  set -x
  typeset integer qmeCnt0=4
  ps -ef|grep qme|grep -v 'grep'
  qmeCnt1=`ps -ef|grep qme|grep -v 'grep'|wc -l`
  (( $qmeCnt1 >= $qmeCnt0 ))
}

tuxIsUp(){
  set -x
  # check the tuxedo instance mode
  cd /usr/apps/ipg/ver001/srv/locus
  . ./setenv.locus
  tuxpsr.watch.ksh > /dev/null 2>&1
}

infIsUp(){
  set -x
  typeset db=ipdb
  typeset dbstate=On-Line
  # check the database instance mode  
  cd /home/informix
  . ./setenv.inf ipdb
  currstate=`onstat -u | grep Informix | awk '{ print $8 }'`
  [ $dbstate = $currstate ]
}

locsrvCnt(){
  set -x
  typeset integer locCnt0=10
  # check the locsrv process
  locCnt1=`ps -ef | grep locsrv | grep locus | wc -l` 
  (( $locCnt0 == $locCnt1 ))
}
 
fsUsedIs(){
  set -x
  typeset fs="$1"
  typeset pct="$2"
  # check filesystem /usr/apps & /dmqjtmp usage
  df $fs | awk '{ print $4 }' | tail -1 | egrep "$pct" > /dev/null 2>&1
}

### main

# check the control reference file
[ -f $reFile ] || {
  set -x
  msgLog "Error: no control file"
  msgAlert
  exit 1
}

# check the /usr/apps filesystem usage
AppsDir=/usr/apps
fsUsedIs $AppsDir "(9[0-9]|100)" && {
  set -x
  msgLog "Error: File System $AppsDir is full"
  msgAlert    
  exit 1
}

# check the /dmqjtmp filesystem usage
AppsDir=/dmqjtmp
fsUsedIs $AppsDir "(9[0-9]|100)" && {
  set -x
  msgLog "Error: File System $AppsDir is full"
  msgAlert    
  exit 1
}

# check locsrv server process
locsrvCnt || {
  set -x
  msgLog "Error: Locsrv server process is wrong"
  msgAlert
  exit 1
}

# check informix is up
infIsUp || {
  set -x
  msgLog "Error: Informix is not up"
  msgAlert
  exit 1
}

# check tuxedo is up
tuxIsUp || {
  set -x
  msgLog "Error: Tuxedo is not up"
  msgAlert
  exit 1
}

#No need to check qme, the VPOM has been retired on 2011/04/06
#qmeIsUp || {
#  set -x
#  msgLog "Error: Qmaster queue manager is not up"
#  msgAlert
#  exit 1
#}
  
msgLog "IP all subsystems are up and running"

touch $reFile

exit 0

