#!/bin/ksh
##############################################################################
#
# Name:        alertDog.ksh
#
# Reference:   n/a
#
# Description: monitor the system error report message
#       
# Parameters:  None
#
# Modification History:
#
#   		Date       	Name		Description
#   		-------------------------------------------------------
#		2002-10-22	Bob Chong	Original
#		2006-10-05	Denny Guo	Modified
#
##############################################################################
set -v
set -x

# log and reference files
msgLog=/dmqjtmp/archiveAdogLog/alertDog.log
errRpt=/dmqjtmp/archiveAdogLog/syserr.rpt
reFile=/dmqjtmp/archiveAdogLog/alertDog.ref

# email user list
#set -A AlertList aixsupport@livingstonintl.com \
#                 computerops@livingstonintl.com

set -A AlertList lchen@livingstonintl.com \
                 bchong@livingstonintl.com \
                 dguo@livingstonintl.com \
                 tward@livingstonintl.com \
                 computerops@livingstonintl.com

msgLog(){
  set -x
  print `date` "$1" >> $msgLog
}

msgAction(){
  set -x
#  msg="URGENT: please call the IP Unix administrator immediately!"
#  print "\n$msg\n"
  echo "URGENT: please call the IP Unix administrator immediately!" > $errRpt
  errpt -a >> $errRpt 
}

msgAlert(){
  set -x
  #msgAction | mail -s "IFX01 System Error Message" ${AlertList[*]}
  #mail -s "System Error Reported on IFX01!" ${AlertList[*]} < $errRpt
  mail -s "System Error Reported on IFX01!" aixsupport@livingstonintl.com < $errRpt
  mail -s "System Error Reported on IFX01!" computerops@livingstonintl.com < $errRpt

}

### check the system error message

anyErrpt() {
  set -x 
  typeset integer errptCnt0=0
  errptCnt1=`errpt | wc -l`
  (( $errptCnt0 == $errptCnt1 ))
}

### main

# check the control reference file
[ -f $reFile ] || {
  set -x
  msgLog "Error: no control file"
  msgAlert
  exit 1
}

anyErrpt || {
  set -x
  msgLog "Error: ** System Error Reported! **"
  msgAction && msgAlert
  exit 1
}

msgLog "No Errpt Error Message"

touch $reFile

exit 0

