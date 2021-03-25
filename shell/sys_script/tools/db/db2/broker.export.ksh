#!/usr/bin/ksh

. /home/db2inst1/sqllib/db2profile

cd /home/db2inst1/export

db2 connect to icmnlsdb

#-- db2 "export to myfile.ixf of ixf messages msgs.txt select * from staff "
#-- db2 "import from myfile.ixf of ixf messages msg.txt insert into staff"

db2 "export to BROKER.ixf of ixf select * from ICMADMIN.BROKER"
db2 "export to CLIENT.ixf of ixf select * from ICMADMIN.CLIENT"
db2 "export to PORTS.ixf of ixf select * from ICMADMIN.PORTS"
db2 "export to GATEWAY.ixf of ixf select * from ICMADMIN.GATEWAY"
db2 "export to GATEWAY_PORT_MAP.ixf of ixf select * from ICMADMIN.GATEWAY_PORT_MAP"
db2 "export to TEMPCLIENT.ixf of ixf select * from BROKER.TEMPCLIENT"
db2 "export to TEMPBROKER.ixf of ixf select * from BROKER.TEMPBROKER"
db2 "export to USPORTS.ixf of ixf select * from ICMADMIN.USPORTS"
db2 "export to BROKERADM.ixf of ixf select * from ICMADMIN.BROKERADM"
db2 "export to CLIENTADM.ixf of ixf select * from ICMADMIN.CLIENTADM"
db2 "export to XREFCLIENTBROKERADM.ixf of ixf select * from ICMADMIN.XREFCLIENTBROKERADM"
db2 "export to BROKERADMSB.ixf of ixf select * from ICMADMIN.BROKERADMSB"
db2 "export to CARRIERCODE.ixf of ixf select * from ICMADMIN.CARRIERCODE"
db2 "export to CLIENTADMSB.ixf of ixf select * from ICMADMIN.CLIENTADMSB"

db2 terminate
