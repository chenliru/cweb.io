#!/bin/ksh
###########################################################
# Name:         cgi.idsbackup
###########################################################
set -v
set -x

bkupdate=`date +%Y%m%d%H%M`

aixsupport="aixsupport@livingstonintl.com"
instance=ipdb
tdir=/livebkup
dbimage=$tdir/${instance}_bkup_L0.$bkupdate
dblog=$tdir/${instance}_bkup_L0.$bkupdate.log

. /home/informix/ids115.env $instance
rm -f $tdir/${instance}_bkup_L0*

cat /dev/null > $dbimage
chown informix:informix $dbimage
chmod 660 $dbimage

ontape -v -s -L 0 -t $dbimage <<EOF>> $dblog
^M
^M
EOF

if [ $? != 0 ]
then
 echo "\nError: database backup failed" 
 mail -s "Informix $instance DB backup failed @ ${bkupdate}" $aixsupport < /dev/null
 exit 1
fi

#/archbkup/bin/cgi.checkDBSpace >> $dblog

mail -s "Informix $instance DB backup done @ ${bkupdate}" $aixsupport < $dblog

exit 0
