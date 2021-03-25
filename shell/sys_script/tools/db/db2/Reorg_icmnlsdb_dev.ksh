
. /home/db2inst1/sqllib/db2profile

db2 connect to icmnlsdb
print "start Reorg ..."
date

db2 reorg table ICMADMIN.GATEWAY             allow no access
db2 reorg table ICMADMIN.GATEWAY_PORT_MAP    index ICMADMIN.PK_GATEWY_PORT_MAP allow no access
db2 reorg table ICMADMIN.ICMSTCHECKEDOUT     index ICMADMIN.ICMSXCHECKEDOUT2U  allow no access
db2 reorg table ICMADMIN.ICMSTCOMPILEDACL    index ICMADMIN.ICMSXCOMPILEDACL1X allow no access
db2 reorg table ICMADMIN.ICMSTCOMPILEDPERM   index ICMADMIN.ICMSXCOMPILEDPRM1U allow no access
db2 reorg table ICMADMIN.ICMSTCOMPVIEWATTRS  index ICMADMIN.ICMSXCOMPVIEWATR1U allow no access
db2 reorg table ICMADMIN.ICMSTCOMPVIEWDEFS   index ICMADMIN.ICMSXCOMPVIEWDEF2X allow no access
db2 reorg table ICMADMIN.ICMSTITEMS001001    index ICMADMIN.ICMSXITEMS0010011U allow no access
db2 reorg table ICMADMIN.ICMSTITEMVER001001  allow no access
db2 reorg table ICMADMIN.ICMSTITVIEWID       index ICMADMIN.ICMSXITVIEW1U      allow no access
db2 reorg table ICMADMIN.ICMSTLINKS001001    index ICMADMIN.ICMSXLINKS0010011U allow no access
db2 reorg table ICMADMIN.ICMSTNLSKEYWORDS    index ICMADMIN.ICMSXNLSKEYWORDS1U allow no access
db2 reorg table ICMADMIN.ICMSTPRIVSETS       index ICMADMIN.ICMSXPRIVSETS1U    allow no access
db2 reorg table ICMADMIN.ICMSTUSERS          index ICMADMIN.ICMSXUSERS1U      allow no access
db2 reorg table ICMADMIN.ICMSTUSERGROUPS     index ICMADMIN.ICMSXUSERGROUPS1U allow no access
db2 reorg table ICMADMIN.ICMUT00201001       index ICMADMIN.ICMUX002010011U   allow no access
db2 reorg table ICMADMIN.ICMUT00204001       index ICMADMIN.ICMUX002040011U   allow no access
db2 reorg table ICMADMIN.ICMUT00208001       index ICMADMIN.ICMUX002080011U   allow no access
db2 reorg table ICMADMIN.ICMUT01239001       index ICMADMIN.ICMUX012390012X   allow no access
db2 reorg table ICMADMIN.ICMUT01261001       index ICMADMIN.ICMUX012610012X   allow no access
db2 reorg table ICMADMIN.ICMUT01266001       index ICMADMIN.ICMUX012660011U   allow no access
db2 reorg table ICMADMIN.ICMUT01267001       index ICMADMIN.ICMUX012670012X   allow no access
db2 reorg table ICMADMIN.ICMUT01270001       index ICMADMIN.ICMUX012700011U   allow no access
db2 reorg table ICMADMIN.ICMUT01271001       index ICMADMIN.ICMUX012710012X   allow no access
db2 reorg table ICMADMIN.ICMUT01311001       index ICMADMIN.ICMUX013110011U   allow no access
db2 reorg table ICMADMIN.ICMUT01514001       index ICMADMIN.ICMUX015140011U   allow no access
db2 reorg table ICMADMIN.ICMUT01515001       index ICMADMIN.ICMUX015150012X   allow no access
db2 reorg table ICMADMIN.ICMUT01528001       index ICMADMIN.ICMUX015280011U   allow no access
db2 reorg table ICMADMIN.ICMUT01529001       index ICMADMIN.ICMUX015290012X   allow no access
db2 reorg table ICMADMIN.ICMUT01530001       index ICMADMIN.ICMUX015300012X   allow no access
db2 reorg table ICMADMIN.ICMUT01639001       index ICMADMIN.ICMUX016390011U   allow no access
db2 reorg table ICMADMIN.ICMUT01647001       index ICMADMIN.ICMUX016470011U   allow no access
db2 reorg table ICMADMIN.ICMUT01695001       index ICMADMIN.ICMUX016950012X   allow no access
db2 reorg table ICMADMIN.ICMUT01972001       index ICMADMIN.ICMUX019720012X   allow no access
db2 reorg table ICMADMIN.ICMUT02042001       index ICMADMIN.ICMUX020420011U   allow no access
db2 reorg table ICMADMIN.ICMUT02043001       index ICMADMIN.ICMUX020430012X   allow no access
db2 reorg table ICMADMIN.ICMUT02227001       index ICMADMIN.ICMUX022270012X   allow no access
db2 reorg table ICMADMIN.ICMUT02531001       index ICMADMIN.ICMUX025310011U   allow no access
db2 reorg table ICMADMIN.ICMUT02594001       index ICMADMIN.ICMUX025940012X   allow no access
                                             
db2 reorg table ICMADMIN.ICMSTITEMSTODELETE  allow no access
db2 reorg table ICMADMIN.CLIENTADM           index ICMADMIN.CC1184337175552   allow no access
db2 reorg table ICMADMIN.BROKERADM           index ICMADMIN.CC1184337501521   allow no access
db2 reorg table ICMADMIN.XREFCLIENTBROKERADM index ICMADMIN.CC1184336321769   allow no access


print "Reorg is completed!!"
date 
db2 terminate
