echo "FTP NMON RawData and analyser script"

FOR %%G IN  (admsrv1,admsrv2) DO (
   cd /D J:\IT\CDN_IT\AIXSupport\
   ftp -i -s:C:\NMON\NMONLMSftp.txt %%G
   "nmon analyser v34a.xls"
   copy *.nmon J:\IT\CDN_IT\AIXSupport\NMON\%%G\RawData\
   copy *.xlsx J:\IT\CDN_IT\AIXSupport\NMON\%%G\FinishedData\
   del /F *.nmon
   del /F *.xlsx )

set RESEXE=0
