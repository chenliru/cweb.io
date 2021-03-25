#!/bin/ksh
################################################################################
#
# Name:		ptrLogClean.ksh
#
# Reference:    n/a
#
# Description:	cleanup the ptr files under /usr/apps/dmq/beta
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
find /usr/apps/dmq/beta -name "dmqptr_*.ptr" -type f -mtime +3 -exec /usr/bin/rm -f {} \; \
> /dev/null 2>&1

find /usr/apps/dmq/beta -name "113410_000*.MMA" -type f -mtime +3 -exec /usr/bin/rm -f {} \; \
> /dev/null 2>&1

exit 0

