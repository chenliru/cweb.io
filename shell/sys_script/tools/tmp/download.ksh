# Start archive database on ifx01, and prepare the Monthly data unload SQL files for client

. /home/lchen/ids115.env ardb
cd /home/lchen/tools/db/informix/download/126706

# for i in 10 11 12; do dbaccess - 2008$i.sql; done
for i in 09 10 11 12; do dbaccess - 2009$i.sql; done
for i in 01 02 03 04 05 06 07 08 09 10 11 12; do dbaccess - 2010$i.sql; done
for i in 01 02 03 04 05 06 07 08 09 10 11 12; do dbaccess - 2011$i.sql; done
for i in 01 02 03 04 05 06 07 08 09 10 11 12; do dbaccess - 2012$i.sql; done
for i in 01 02; do dbaccess - 2013$i.sql; done

cd /home/lchen/tools/db/informix/download/126706

cat entry.head 200909.tmp 200910.tmp 200911.tmp 200912.tmp 201001.tmp 201002.tmp 201003.tmp 201004.tmp 201005.tmp 201006.tmp 201007.tmp 201008.tmp 201009.tmp 201010.tmp 201011.tmp 201012.tmp 201101.tmp 201102.tmp 201103.tmp 201104.tmp 201105.tmp 201106.tmp 201107.tmp 201108.tmp 201109.tmp 201110.tmp 201111.tmp 201112.tmp 201201.tmp 201202.tmp 201203.tmp 201204.tmp 201205.tmp 201206.tmp 201207.tmp 201208.tmp 201209.tmp 201210.tmp 201211.tmp 201212.tmp 201301.tmp 201302.tmp > oldshipment126706

