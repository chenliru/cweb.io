#!/bin/ksh
#===============================================================================
# All rights reserved - CGI
#===============================================================================
# Name    : nmon_script.ksh
# Creation: 2015/06 - Version 01.00 - By Harry Dong 
# Desc    : 
# ------------------------------------------------------------------------------
# Revision: xx/xx/xxxx - Version xx.xx - By xxxxxxx xxxxxxx
# Desc.   : xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
# ------------------------------------------------------------------------------
# Revision: xx/xx/xxxx - Version xx.xx - By xxxxxxx xxxxxxx
# Desc.   : xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
# ------------------------------------------------------------------------------
#===============================================================================

#===============================================================================
# MAIN
#===============================================================================
typeset -r SERVER=`uname -n`
SERVERHOSTNAME=$(echo $SERVER | awk 'FS = "-" { print $1 }')
LOGDIR=/insight/${SERVERHOSTNAME}/nmon
nmon -f -t -m $LOGDIR -s 600 -c 144
find $LOGDIR/ -mtime +30 -exec rm {} \;
exit 0
