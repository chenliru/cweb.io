echo "FTP NMON RawData and analyser script"

FOR %%G IN  (ecm01,ecm02,ecm03,ecm04,ecm05,ecm06,ecm07,ecm08,ecm09,ecm10,ecm11,ecm12) DO (
   cd /D J:\IT\CDN_IT\AIXSupport\
   ftp -i -s:C:\NMON\NMONisisftp.txt %%G
   "nmon analyser v34a.xls"
   copy *.nmon J:\IT\CDN_IT\AIXSupport\NMON\%%G\RawData\
   copy *.xlsx J:\IT\CDN_IT\AIXSupport\NMON\%%G\FinishedData\
   del /F *.nmon
   del /F *.xlsx )

set RESEXE=0
