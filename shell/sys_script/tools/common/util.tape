#!/bin/ksh
###########################################################################################
#
# Name:         utilize.tape
#
# Reference:    n/a
#
# Description:  The utilize.tape command gives subcommands to a streaming tape 
#               device. 
#
# Command:      utilize.tape <tapedevice> <action> <count>
#
#               <tapedevice> 
#               Device variable must specify a raw (not block) tape device.
#               For example:
#                on AIX: /dev/rmt0; /dev/rmt0.1(no rewind)
#                on SunOS: /dev/rmt/0; /dev/rmt/0n(no rewind)
#                default: $BACKUPDEVICE
#
#               <action>
#               1. "eof" or "weof": Writes the number of end-of-file markers specified 
#               by the Count parameter at the current position on the tape. 
#               On an 8 mm tape drive, an end-of-file marker can be written in three places: 
#                  - Before blank tape 
#                  - Before an extended file mark 
#                  - At the beginning-of-tape mark
#               On a 9-track tape drive, the end-of-tape marker can be written at
#               any location on the tape. However, this subcommand does not support 
#               overwriting single blocks of data.
#               2. "fsf": Moves the tape forward the number of file marks specified
#               by the Count parameter and positions it on the end-of-tape (EOT) 
#               side of the file mark. 
#               3. "bsf": Moves the tape backward the number of file marks specified by 
#               the Count parameter and positions it on the beginning-of-tape (BOT) 
#               side of the file mark. 
#               If the bsf subcommand moves the tape past the beginning, the tape rewinds, 
#               and the tctl command returns EIO. 
#               4. "fsr": Moves the tape forward the number of records specified by the 
#               Count parameter. 
#               5. "bsr": Moves the tape backwards the number of records specified
#               by the Count parameter. 
#               6. "rewind": Rewinds the tape. The Count parameter is ignored. 
#               7. "offline" or "rewoffl": Rewinds the tape and takes the tape drive offline.
#               This will unload the tape when appropriate. The tape must be re-inserted
#               before the device can be used again. 
#               8. "erase": Erases all contents on the tape and rewinds it. 
#               9. "read": Reads from the specified tape device (using the specified block size)
#               until the internal buffer is full, and then writes the data to standard 
#               output, continuing to read and write this way until an end-of-file (EOF) 
#               mark is reached. 
#               10. "reset": Sends a bus device reset (BDR) to the tape device. 
#               The BDR will only be sent if the device cannot be opened and is not busy. 
#               11. "retension": Moves the tape to the beginning, then to the end, 
#               and then back to the beginning of the tape. 
#               If you have excessive read errors during a restore operation, you should run
#               the retension subcommand. 
#               If the tape has been exposed to environmental extremes, you should run the
#               retension subcommand before writing to tape. 
#               The 8 mm tape drive will not respond to this command. 
#               11. "status": Prints status information about the specified tape device. 
#               12. "write": Opens the tape device, reads from standard input, and writes the
#               data to the tape device. 
#
#               <count>
#               There maybe mutiple files(or archives) on one single tape, use the Count
#               parameter specifies the number of end-of-file markers,
#               number of file marks, or number of records. If the Count parameter
#               is not specified, the default count is 1.
#
#################################################################################################
set -x
set -v

. ~/tools.profile

TAPEDEVICE=${1-$BACKUPDEVICE}
ACTION=${2-status}
COUNT=${3-1}

[[ `uname` = AIX ]] && tapecommand=tctl
[[ `uname` = SunOS ]] && tapecommand=mt
[[ `uname` = Linux ]] && tapecommand=mt

loadtape() {
  #Rewind the tape volume
   $tapecommand -f $TAPEDEVICE rewind

  #Check Backup device and tape status.
   while [[ $? != 0 ]]
   do
    utilize.journal record $ERRFILE \
      "\nError: Backup Device or Tape is not ready, \
         Please mount tape $TAPEDEVICE ..."

    #Send email to system administrator until tape is ready.
    mail -s "Please mount tape $TAPEDEVICE" $SYSADMEMAIL < $ERRFILE
    sleep 30
    $tapecommand -f $TAPEDEVICE rewind
   done
}

#####################
# main
#####################
case $ACTION in
   load) loadtape ;;
   *) $tapecommand -f $TAPEDEVICE $ACTION $COUNT ;;
esac

