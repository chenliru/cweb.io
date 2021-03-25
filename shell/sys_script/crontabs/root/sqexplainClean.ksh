#!/usr/bin/ksh

# null the sqexplain out & other log files
0 0 * * * cat /dev/null > /home/ipgown/sqexplain.out
0 0 * * * cat /dev/null > /home/ipinsdoc/sqexplain.out
0 0 * * * cat /dev/null > /home/ipuser/sqexplain.out
0 0 * * * cat /dev/null > /home/insrpt/sqexplain.out
0 0 * * * cat /dev/null > /usr/apps/ipg/ver001/srv/locus/sqexplain.out
0 0 * * * cat /dev/null > /usr/apps/ipg/ver001/srv/insight/sqexplain.out
0 0 * * * cat /dev/null > /usr/apps/ipg/ver001/srv/bds/pgm/ip_0p/sqexplain.out
