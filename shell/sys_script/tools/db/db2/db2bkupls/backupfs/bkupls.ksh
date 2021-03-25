#!/bin/ksh

bkupdate=bkup.`date +%y%m%d`

cd /home/db2inst1
find . -print | backup -ivqf  /db2bkupls/backupfs/db2inst1.$bkupdate > /db2bkupls/backupfs/db2inst1.$bkupdate.out 2>&1

cd /home/db2fenc1
find . -print | backup -ivqf  /db2bkupls/backupfs/db2fenc1.$bkupdate > /db2bkupls/backupfs/db2fenc1.$bkupdate.out 2>&1

cd /db2logls
find . -print | backup -ivqf  /db2bkupls/backupfs/db2logls.$bkupdate > /db2bkupls/backupfs/db2logls.$bkupdate.out 2>&1

exit 0

