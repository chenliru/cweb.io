#!/bin/ksh
###########################################################
# Name:         cgi.idsbackup
###########################################################
set -v
set -x

bkupdate=`date +%Y%m%d%H%M`

/archbkup/bin/cgi.checkDBSpace > ~/tools/chunks

mail -s "IFX01 ipdb chunks usage!" lchen@livingstonintl.com < ~/tools/chunks

exit 0
