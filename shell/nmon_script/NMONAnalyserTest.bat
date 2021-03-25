echo "FTP NMON RawData and analyser script"

FOR %%G IN  (ifx01,admsvr1) DO (
   cd /D J:\IT\CDN_IT\AIXSupport\NMON
   cd %%G\RawData
   del /F *.*
   ftp -i -s:C:\NMON\NMONftp.txt %%G
   cd /D J:\IT\CDN_IT\AIXSupport\NMON\%%G
   "nmon_analyser.xls" )

set RESEXE=0
