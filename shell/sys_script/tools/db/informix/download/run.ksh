# Start archive database on ifx01, and prepare the Monthly data unload SQL files for client

. /home/lchen/ids117.env ol_informix1170
cd /home/lchen/download

for i in 10 11 12; do dbaccess - 2008$i.sql; done
for i in 01 02 03 04 05 06 07 08 09 10 11 12; do dbaccess - 2009$i.sql; done
for i in 01 02 03 04 05 06 07 08 09 10 11 12; do dbaccess - 2010$i.sql; done
for i in 01 02 03; do dbaccess - 2011$i.sql; done

cd /home/lchen/download/298917

cat entry.head 200810.tmp 200811.tmp 200812.tmp 200901.tmp 200902.tmp 200903.tmp 200904.tmp 200905.tmp 200906.tmp 200907.tmp 200908.tmp 200909.tmp 200910.tmp 200911.tmp 200912.tmp 201001.tmp 201002.tmp 201003.tmp 201004.tmp 201005.tmp 201006.tmp 201007.tmp 201008.tmp 201009.tmp 201010.tmp 201011.tmp 201012.tmp 201101.tmp 201102.tmp 201103.tmp > oldshipment298917

