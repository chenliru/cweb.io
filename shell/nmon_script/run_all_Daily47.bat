cd C:\NMON\out

"%windir%\system32\WindowsPowerShell\v1.0\PowerShell.exe" "C:\NMON\nmon_Daily.ps1"

copy controlIPRO.txt control.txt
"C:\Program Files\Microsoft Office\Office14\excel.exe" "aNmonD47.xlsm"

move /Y ecm01_1* ecm01.xlsx
move /Y ecm02_1* ecm02.xlsx
move /Y ecm03_1* ecm03.xlsx
move /Y ecm04_1* ecm04.xlsx
move /Y ecm05_1* ecm05.xlsx
move /Y ecm06_1* ecm06.xlsx
move /Y ecm07_1* ecm07.xlsx
move /Y ecm08_1* ecm08.xlsx
move /Y ecm09_1* ecm09.xlsx
move /Y ecm10_1* ecm10.xlsx
move /Y ecm11_1* ecm11.xlsx

set MacroName=MACRO.XLSM!Macro1
"C:\Program Files\Microsoft Office\Office14\excel.exe" ecm01.xlsx MACRO.XLSM 
"C:\Program Files\Microsoft Office\Office14\excel.exe" ecm02.xlsx MACRO.XLSM 
"C:\Program Files\Microsoft Office\Office14\excel.exe" ecm03.xlsx MACRO.XLSM 
"C:\Program Files\Microsoft Office\Office14\excel.exe" ecm04.xlsx MACRO.XLSM 
"C:\Program Files\Microsoft Office\Office14\excel.exe" ecm05.xlsx MACRO.XLSM 
"C:\Program Files\Microsoft Office\Office14\excel.exe" ecm06.xlsx MACRO.XLSM 
"C:\Program Files\Microsoft Office\Office14\excel.exe" ecm07.xlsx MACRO.XLSM 
"C:\Program Files\Microsoft Office\Office14\excel.exe" ecm08.xlsx MACRO.XLSM 
"C:\Program Files\Microsoft Office\Office14\excel.exe" ecm09.xlsx MACRO.XLSM 
"C:\Program Files\Microsoft Office\Office14\excel.exe" ecm10.xlsx MACRO.XLSM 
"C:\Program Files\Microsoft Office\Office14\excel.exe" ecm11.xlsx MACRO.XLSM 

copy controlLOIS.txt control.txt
"C:\Program Files\Microsoft Office\Office14\excel.exe" "aNmonD47.xlsm"

move /Y wes01_1* wes01.xlsx
move /Y wes02_1* wes02.xlsx
move /Y ihs01_1* ihs01.xlsx
move /Y ihs02_1* ihs02.xlsx
move /Y was01_1* was01.xlsx
move /Y was02_1* was02.xlsx
move /Y icm01_1* icm01.xlsx
move /Y icm02_1* icm02.xlsx
move /Y tsm01_1* tsm01.xlsx
move /Y ipm02_1* ipm02.xlsx

set MacroName=MACRO.XLSM!Macro1
"C:\Program Files\Microsoft Office\Office14\excel.exe" wes01.xlsx MACRO.XLSM 
"C:\Program Files\Microsoft Office\Office14\excel.exe" wes02.xlsx MACRO.XLSM 
"C:\Program Files\Microsoft Office\Office14\excel.exe" ihs01.xlsx MACRO.XLSM 
"C:\Program Files\Microsoft Office\Office14\excel.exe" ihs02.xlsx MACRO.XLSM 
"C:\Program Files\Microsoft Office\Office14\excel.exe" was01.xlsx MACRO.XLSM 
"C:\Program Files\Microsoft Office\Office14\excel.exe" was02.xlsx MACRO.XLSM 
"C:\Program Files\Microsoft Office\Office14\excel.exe" icm01.xlsx MACRO.XLSM 
"C:\Program Files\Microsoft Office\Office14\excel.exe" icm02.xlsx MACRO.XLSM 
"C:\Program Files\Microsoft Office\Office14\excel.exe" tsm01.xlsx MACRO.XLSM 
"C:\Program Files\Microsoft Office\Office14\excel.exe" ipm02.xlsx MACRO.XLSM 

copy controlKEC.txt control.txt
"C:\Program Files\Microsoft Office\Office14\excel.exe" "aNmonD47.xlsm"
copy controlLINUX.txt control.txt
"C:\Program Files\Microsoft Office\Office14\excel.exe" "aNmonD505.xlsm"

move /Y kc1prdb01_2* kc1prdb01.xlsx
move /Y kc1prapkc01_2* kc1prapkc01.xlsx
move /Y kc1prapkc02_2* kc1prapkc02.xlsx
move /Y kc2prapkc02_2* kc2prapkc02.xlsx
move /Y kc1prapal01_1* kc1prapal01.xlsx

set MacroName=LINUXMACRO.XLSM!linux
"C:\Program Files\Microsoft Office\Office14\excel.exe" kc1prdb01.xlsx LINUXMACRO.XLSM
"C:\Program Files\Microsoft Office\Office14\excel.exe" kc1prapkc01.xlsx LINUXMACRO.XLSM
"C:\Program Files\Microsoft Office\Office14\excel.exe" kc1prapkc02.xlsx LINUXMACRO.XLSM
"C:\Program Files\Microsoft Office\Office14\excel.exe" kc2prapkc02.xlsx LINUXMACRO.XLSM
"C:\Program Files\Microsoft Office\Office14\excel.exe" kc1prapal01.xlsx MACRO.XLSM 

"%windir%\system32\WindowsPowerShell\v1.0\PowerShell.exe" -noexit "C:\NMON\refresh_Daily.ps1"
