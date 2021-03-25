#!/bin/ksh
################################################################################
#
# Name:		bkupLogClean.ksh
#
# Reference:    n/a
#
# Description:	cleanup the backup log files under /sitemgr/backup/workarea
#
# Parameters:   None
#
# Modification History:
# 
# 		Date		Name		Description
# 		-------------------------------------------------------
# 		2002-10-25	Bob Chong	Original
#
##################################################################################
set -x
date

find /dmqjtmp/archiveSysbkupLog -mtime +30 -exec /usr/bin/rm -f {} \; \
> /dev/null 2>&1

find /dmqjtmp/archiveAppbkupLog -mtime +7 -exec /usr/bin/rm -f {} \; \
> /dev/null 2>&1

find /dmqjtmp/archiveDbsbkupLog -mtime +7 -exec /usr/bin/rm -f {} \; \
> /dev/null 2>&1

find /dmqjtmp/archiveFfileLog -mtime +7 -exec /usr/bin/rm -f {} \; \
> /dev/null 2>&1

exit 0

