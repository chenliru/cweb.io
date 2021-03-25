#!/bin/ksh
#####################################################################
#
# Name:        	runner.all.ksh
#
# Reference:   	n/a
#
# Description: 	Runner for the Reader
#               Processing all queues file;
#       
# Parameters:  	None
#
# Modification History:
#
#   		Date       	Name          Description
#   		------------------------------------------------
#   		2002-10-01 	Bob Chong     Original
#
#####################################################################

set -v
set -x

date

typeset -ft rdrIsAvailable rdrStart
typeset -fu rdrIsAvailable rdrStart

# DMQ environment variable
Bus=11
Group=34

# Queue number
QueList="10 21 22 31 32 34 41 51 52 70 81"
#QueList="21 22 31 32 34 41 51 52 70 81"

#Queue 46 been disabled due to no feed from LOCUS 
#and Q46 reader also disabled on LOCUS since 1998;
#QueList="10 21 22 31 32 34 41 46 51 52 70 81"

DmqJtmp=/dmqjtmp
RdrVaxFileDir=$DmqJtmp/rcp
RdrVaxFileArDir=$RdrVaxFileDir/done

DmqVaxHome=/dmqjtmp/dmqvax
RdrVaxTokenDir=$DmqVaxHome/token
RdrVaxTokenArDir=$DmqVaxHome/tokendone
RdrVaxTokenErrDir=$DmqVaxHome/tokenerror

Log=/dmqjtmp/archiveRunnerLog/runner.log
RefFile=/dmqjtmp/archiveRunnerLog/runner.ref

AppsDir=/usr/apps
BetaDir=$AppsDir/dmq/beta
aixsupport="aixsupport@livingstonintl.com"

Tcl=./tcl
RdrTraceLevel=3
#RdrTraceLevel=4

msgLog(){
  print `date` "$1" >> $Log
}

rdrStart(){
  set -x
  typeset q=$1 f=$2
  typeset betaEnv=dmqbeta own=bbois  
  typeset workFile=$BetaDir/$Bus$Group${q}.DMQIN

  msgLog "Processing $q now"
  ln -sf $f $workFile
  chmod 644 $f
  
su - $own >>/dev/null 2>&1 <<%
cd /usr/apps/ipg/ver001/srv/locus
. setenv.locus
cd /usr/apps/dmq/beta
export DMQ_FULL_AUDIT_$q=FILE
$Tcl $q $RdrTraceLevel &
%

#AWS project, added by Liru 2016-01-09
cp -p $f $RdrVaxFileDir/stage/done

  return 0
} 

GetNextFile(){
  set -x
  typeset t f
  integer size=0 
 
  # get the first one 70.1.vax 70.2.vax 70.3.vax 
  for i
  do
    t=$RdrVaxTokenDir/$i
    f=$RdrVaxFileDir/$i

    [ -f $f ] || {
	msgLog "Panic: Missing file for token $i ???"
  	mv $t $RdrVaxTokenErrDir
	continue
    }

    [ -s $f ] || {
	msgLog "Panic: Empty file for token $i ???"
	mv $t $RdrVaxTokenErrDir
	mv $f $RdrVaxFileArDir
	continue
    }

    ((size=$(ls -l $f | awk '{ print $5 }'))) 
    msgLog "Processing $i size = ${size} ready " 

    sleep 4	#Added due to processing issue;
    chmod 644 $f
    mv $t $RdrVaxTokenArDir
    mv $f $RdrVaxFileArDir
    print $RdrVaxFileArDir/$i
    return 0
  done
  return 1
}

timeRefFileCreate(){
  set -x
  typeset q=${1-??}
  integer x=${2-5}
  typeset ref=/usr/apps/dmq/beta/xtime.0$q 
  integer m=$(date +%m) d=$(date +%d) h=$(date +%H) n=$(date +%M)

  if (( $n >= 5 ))
  then
     ((n=n-x))
  else
     return 0 
  fi

  typeset -Z2 m d h n 
  touch -t ${m}${d}${h}${n} $ref 
  print $ref
}

rdrIsActive(){
  set -x
  typeset q=${1-??}
  typeset min=${2-5} 
  typeset dir=${3-$BetaDir}
  typeset ref=$(timeRefFileCreate $q $min)
  typeset rdLog=dmqlog.0$q
  typeset list

  # if dmqlog.0?? file is not updated in 5 mins, then stop 
  find $dir -type f -newer ${ref} -print | grep "dmqlog.0$q" > /dev/null 2>&1
}  

rdrIsUp(){
  set -x
  typeset q=$1 

  # if current reader not found, then prepare to process the current queue
  #ps -ef | grep "[0-9] $Tcl $q $RdrTraceLevel" > /dev/null 2>&1
  ps -ef | grep "$Tcl $q $RdrTraceLevel"|grep -v "grep" > /dev/null 2>&1
}

rdrIsAvailable(){
  set -x
  typeset q=$1

  # is reader running
  rdrIsUp $q || {
     msgLog "Reader $q is not running"
     return 0 
  }

  msgLog "Reader $q is running"

  # is reader working
  rdrIsActive $q && {
     msgLog "Reader $q is running and working"
     return 1
  }

  msgLog "Reader $q is running but not working"
  return 1
}

lnName(){
  set -x
  typeset lnk=$1 nameLong nameShort

  [ -L $lnk ] || return 1
  nameLong=$(ls -l $lnk | awk '{print $11}') 
  nameShort=${nameLong##*/} 
  print $nameShort
}

fileSize(){
  set -x
  typeset f i
  integer size s

  for i
  do
    f=$RdrVaxFileDir/$i
    s=$(ls -l $f 2>/dev/null | awk '{ print $5 }')
    size=size+s
  done
  print $size
}

tokenList(){
  set -x
  typeset q=$1
  typeset pat=${q}*.vax
  typeset list
 
  # no token ( 0 ) means false ( 1 ); otherwise print the files 
  set -A list $(cd $RdrVaxTokenDir; ls $pat 2> /dev/null)
  ((${#list[*]})) && print ${list[*]}
}

tokenSetLast(){
  set -x
  typeset q=$1
  typeset Last=$RdrVaxTokenDir/Last.$q	# point to the last token file
  typeset list name f

  # no token file then goto next queue
  echo "\n==== Check whether there is any token file for Queue $q..."
  set -A list $(tokenList $q)
  ((${#list[*]})) || { 
     msgLog "No token file for $q"
     return 1 
  }
 
  msgLog "Reader $q total file = ${#list[*]} total size = $(fileSize ${list[*]})"  

  # set the last token file
  integer n=$((${#list[*]}-1))
  name=${list[n]}

  # same file then process next file
  [ "$(lnName $Last)" = $name ] && {
     msgLog "Reader $q no new file arrived "
     return 0 
  } 

  # link the last file
  f=$RdrVaxFileDir/$name
  ln -sf $f $Last

  msgLog "Reader $q received $name "  
}

### processing each queue transaction

rdrProc(){
  set -x
  typeset q=$1
  typeset Cur=$DmqVaxHome/Cur.$q	# point to the current file
  typeset Last list f
  
  echo "\n ==  Handling the Queue in detail for Queue : $q @ `date` ==\n"

  # set the last token file received
  echo "\n==== # set the last token file received ...."
  tokenSetLast $q || {
     msgLog "Goto next queue" 
     return 0
  }

  # is reader available
  echo "\n==== Verify whether reader is available ..."
  rdrIsAvailable $q || {
     msgLog "Reader $q is not available"
     return 0
  }

  # reader is available: let log the end of work, set Cur, Last Ptr 
  echo "\n======# reader is available: let log the end of work, set Cur, Last Ptr ..."
  [ -L $Cur ] && {
     Last=$DmqVaxHome/Last.$q
     mv $Cur $Last
     msgLog "Reader $q file = $(lnName $Last) done"
  }

  # check for more to-do
  echo "\n==== Get token file for Queue $q ...."
  set -A list $(tokenList $q)
  ((${#list[*]})) || return 0

  # get the next file
  echo "\n==== Get first available file in Queue $q to process ...."
  print "allnextfile=${list[*]}"
  f=$(GetNextFile ${list[*]})
  print "nextfile=$f"
  [ "$f" ] || return 0

  # set the current file
  ln -sf $f $Cur

  # start the reader
  echo "\n===== Start the actual reader for $f @ `date`====\n"
  rdrStart $q $f
}

### check the environments and subsystems

tuxIsUp(){
  set -x

  # check the tuxedo instance mode
  cd /usr/apps/ipg/ver001/srv/locus
  . ./setenv.locus
  # bchong 2003/07/15 ulog error 557
  # tuxpsr.ksh > /dev/null 2>&1
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
  typeset locCnt0=10

  # check the locsrv process
  locCnt1=`ps -ef | grep locsrv | grep locus | wc -l` 
  (( $locCnt0 == $locCnt1 ))
}
 
fsUsedIs(){
  set -x
  typeset fs="$1"
  typeset pct="$2"

  # check filesystem /usr/apps usage
  df $fs | awk '{ print $4 }' | tail -1 | egrep "$pct" > /dev/null 2>&1
}

### main program starts from here;

# check the control reference file
date
echo "+++++ Control file check ....."
[ -f $RefFile ] || {
  set -x
  msgLog "Error: no control file"
  exit 1
}

# check the /usr/apps filesystem usage
date
echo "+++++ /usr/apps Disk Space check ....."
fsUsedIs $AppsDir "(9[0-9]|100)" && {
  set -x
  msgLog "Error: File System $AppsDir is full"
  mail -s "$AppsDir File System Space Low!!!" $aixsupport </dev/null
  exit 1
}

# check the /dmqjtmp filesystem usage
date
echo "+++++ /dmqjtmp Disk Space check ....."
fsUsedIs $DmqJtmp "(9[0-9]|100)" && {
  set -x
  msgLog "Error: File System $DmqJtmp is full"
  mail -s "$DmqJtmp File System Space Low!!!" $aixsupport </dev/null
  exit 1
}

# check locsrv server process
date
echo "+++++  Locus Service check ...."
locsrvCnt || {
  set -x
  msgLog "Error: Locsrv server process is wrong"
  mail -s "Locsrv Server process is wrong!!!" $aixsupport </dev/null
  exit 1
}

# check informix is up
date
echo "+++++ Informix check ...."
infIsUp || {
  set -x
  msgLog "Error: Informix is not up"
  mail -s "Informix Server is not up!!!" $aixsupport </dev/null
  exit 1
}

# check tuxedo is up
date
echo "+++++ Tuxedo check ..."
tuxIsUp || {
  set -x
  msgLog "Error: Tuxedo is not up"
  mail -s "Tuxedo Server is not up!!!" $aixsupport </dev/null
  exit 1
}

date
echo "+++++ Token Directory check ..."
[ -d $RdrVaxTokenDir ] || mkdir $RdrVaxTokenDir
[ -d $RdrVaxTokenArDir ] || mkdir $RdrVaxTokenArDir
[ -d $RdrVaxTokenErrDir ] || mkdir $RdrVaxTokenErrDir

echo "\n*** Start to process each queue @ `date` ****\n"

msgLog "\n<--- RUNNER opening --->"
for i in $QueList
do
   msgLog "Reader $i start  ###"
   echo "\n ======  Start to handle Queue : $i  @ `date`  ======\n"
   rdrProc $i
   msgLog "Reader $i finish ###\n\n"
done
msgLog "<--- RUNNER closing --->\n"

touch $RefFile

exit 0

