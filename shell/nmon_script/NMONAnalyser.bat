echo "FTP NMON RawData and analyser script"

FOR %%G IN  (ifx01,wes01,wes02,ihs01,ihs02,was01,was02,icm01,icm02,tsm01,nim02,ipm02,ecm01,ecm02,ecm03,ecm04,ecm05,ecm06,ecm07,ecm08,ecm09,ecm10,ecm11,ecm12,admsrv1,admsrv2,codaweb1,codaweb2,codaapp1,codaapp2,codadb1,codadb2,codatest,cm01,cm02,cm05,cm07) DO (
   cd /D J:\IT\CDN_IT\AIXSupport\NMON
   cd %%G\RawData
   del /F *.*
   ftp -i -s:C:\NMON\NMONftp.txt %%G
   cd /D J:\IT\CDN_IT\AIXSupport\NMON\%%G
   "nmon_analyser.xls" )

set RESEXE=0
