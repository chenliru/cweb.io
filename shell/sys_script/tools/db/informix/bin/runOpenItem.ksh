#!/usr/bin/ksh
set -x 
#
# Download Table client_invoice before load data
#
DATE=`date +%Y%m%d`
cd /home/lchen
. ./ids115.env ipdb

cd /home/lchen/scripts/informix
dbaccess - unload_client_invoice.sql
mv /recyclebox/lchen/openItem/ifx01.client_invoice /recyclebox/lchen/openItem/ifx01.client_invoice$DATE
mv /insight/local/scripts/ICCBillingUpload/unhandled_excps.out /recyclebox/lchen/openItem/unhandled_excps.out$DATE

find /recyclebox/lchen/openItem -mtime +4 -exec rm -f {} \;

#
# Load data to Table client_invoice
#
# ksh /dmqjtmp/rcp/openItem/runStartInsightBillingUpload.ksh 
mv /dmqjtmp/rcp/*.recv /dmqjtmp/rcp/openItem
nohup /insight/local/scripts/ICCBillingUpload/StartInsightBillingUpload.ksh>> /insight/local/scripts/ICCBillingUpload/StartInsightBillingUpload.out &


