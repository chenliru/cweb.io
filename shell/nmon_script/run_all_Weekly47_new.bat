cd C:\NMON\out

"%windir%\system32\WindowsPowerShell\v1.0\PowerShell.exe" "C:\NMON\nmon_Weekly_new.ps1"

copy nw_control_ecm01.txt w_control.txt
"C:\Program Files\Microsoft Office\Office14\excel.exe" "aNmonW47.xlsm"
copy nw_control_ecm02.txt w_control.txt
"C:\Program Files\Microsoft Office\Office14\excel.exe" "aNmonW47.xlsm"
copy nw_control_ecm03.txt w_control.txt
"C:\Program Files\Microsoft Office\Office14\excel.exe" "aNmonW47.xlsm"
copy nw_control_ecm04.txt w_control.txt
"C:\Program Files\Microsoft Office\Office14\excel.exe" "aNmonW47.xlsm"
copy nw_control_ecm05.txt w_control.txt
"C:\Program Files\Microsoft Office\Office14\excel.exe" "aNmonW47.xlsm"
copy nw_control_ecm06.txt w_control.txt
"C:\Program Files\Microsoft Office\Office14\excel.exe" "aNmonW47.xlsm"
copy nw_control_ecm07.txt w_control.txt
"C:\Program Files\Microsoft Office\Office14\excel.exe" "aNmonW47.xlsm"
copy nw_control_ecm08.txt w_control.txt
"C:\Program Files\Microsoft Office\Office14\excel.exe" "aNmonW47.xlsm"
copy nw_control_ecm09.txt w_control.txt
"C:\Program Files\Microsoft Office\Office14\excel.exe" "aNmonW47.xlsm"
copy nw_control_ecm10.txt w_control.txt
"C:\Program Files\Microsoft Office\Office14\excel.exe" "aNmonW47.xlsm"
copy nw_control_ecm11.txt w_control.txt
"C:\Program Files\Microsoft Office\Office14\excel.exe" "aNmonW47.xlsm"

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

"C:\Program Files\Microsoft Office\Office14\excel.exe" ecm01.xlsx w_MACRO.XLSM 
"C:\Program Files\Microsoft Office\Office14\excel.exe" ecm02.xlsx w_MACRO.XLSM 
"C:\Program Files\Microsoft Office\Office14\excel.exe" ecm03.xlsx w_MACRO.XLSM 
"C:\Program Files\Microsoft Office\Office14\excel.exe" ecm04.xlsx w_MACRO.XLSM 
"C:\Program Files\Microsoft Office\Office14\excel.exe" ecm05.xlsx w_MACRO.XLSM 
"C:\Program Files\Microsoft Office\Office14\excel.exe" ecm06.xlsx w_MACRO.XLSM 
"C:\Program Files\Microsoft Office\Office14\excel.exe" ecm07.xlsx w_MACRO.XLSM 
"C:\Program Files\Microsoft Office\Office14\excel.exe" ecm08.xlsx w_MACRO.XLSM 
"C:\Program Files\Microsoft Office\Office14\excel.exe" ecm09.xlsx w_MACRO.XLSM 
"C:\Program Files\Microsoft Office\Office14\excel.exe" ecm10.xlsx w_MACRO.XLSM 
"C:\Program Files\Microsoft Office\Office14\excel.exe" ecm11.xlsx w_MACRO.XLSM 

copy nw_control_wes01.txt w_control.txt
"C:\Program Files\Microsoft Office\Office14\excel.exe" "aNmonW47.xlsm"
copy nw_control_wes02.txt w_control.txt
"C:\Program Files\Microsoft Office\Office14\excel.exe" "aNmonW47.xlsm"
copy nw_control_ihs01.txt w_control.txt
"C:\Program Files\Microsoft Office\Office14\excel.exe" "aNmonW47.xlsm"
copy nw_control_ihs02.txt w_control.txt
"C:\Program Files\Microsoft Office\Office14\excel.exe" "aNmonW47.xlsm"
copy nw_control_was01.txt w_control.txt
"C:\Program Files\Microsoft Office\Office14\excel.exe" "aNmonW47.xlsm"
copy nw_control_was02.txt w_control.txt
"C:\Program Files\Microsoft Office\Office14\excel.exe" "aNmonW47.xlsm"
copy nw_control_icm01.txt w_control.txt
"C:\Program Files\Microsoft Office\Office14\excel.exe" "aNmonW47.xlsm"
copy nw_control_icm02.txt w_control.txt
"C:\Program Files\Microsoft Office\Office14\excel.exe" "aNmonW47.xlsm"
copy nw_control_tsm01.txt w_control.txt
"C:\Program Files\Microsoft Office\Office14\excel.exe" "aNmonW47.xlsm"
copy nw_control_ipm02.txt w_control.txt
"C:\Program Files\Microsoft Office\Office14\excel.exe" "aNmonW47.xlsm"

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

"C:\Program Files\Microsoft Office\Office14\excel.exe" wes01.xlsx w_MACRO.XLSM
"C:\Program Files\Microsoft Office\Office14\excel.exe" wes02.xlsx w_MACRO.XLSM
"C:\Program Files\Microsoft Office\Office14\excel.exe" ihs01.xlsx w_MACRO.XLSM
"C:\Program Files\Microsoft Office\Office14\excel.exe" ihs02.xlsx w_MACRO.XLSM
"C:\Program Files\Microsoft Office\Office14\excel.exe" was01.xlsx w_MACRO.XLSM
"C:\Program Files\Microsoft Office\Office14\excel.exe" was02.xlsx w_MACRO.XLSM
"C:\Program Files\Microsoft Office\Office14\excel.exe" icm01.xlsx w_MACRO.XLSM
"C:\Program Files\Microsoft Office\Office14\excel.exe" icm02.xlsx w_MACRO.XLSM
"C:\Program Files\Microsoft Office\Office14\excel.exe" tsm01.xlsx w_MACRO.XLSM
"C:\Program Files\Microsoft Office\Office14\excel.exe" ipm02.xlsx w_MACRO.XLSM


copy nw_control_kc1prapal01.txt w_control.txt
"C:\Program Files\Microsoft Office\Office14\excel.exe" "aNmonW47.xlsm"
copy nw_control_kc1prapkc01.txt w_control.txt
"C:\Program Files\Microsoft Office\Office14\excel.exe" "aNmonW47.xlsm"
copy nw_control_kc1prapkc02.txt w_control.txt
"C:\Program Files\Microsoft Office\Office14\excel.exe" "aNmonW47.xlsm"
copy nw_control_kc2prapkc02.txt w_control.txt
"C:\Program Files\Microsoft Office\Office14\excel.exe" "aNmonW47.xlsm"
copy nw_control_kc1prdb01.txt w_control.txt
"C:\Program Files\Microsoft Office\Office14\excel.exe" "aNmonW47.xlsm"

move /Y kc1prapal01_1* kc1prapal01.xlsx
move /Y kc1prapkc01_1* kc1prapkc01.xlsx
move /Y kc1prapkc02_1* kc1prapkc02.xlsx
move /Y kc2prapkc02_1* kc2prapkc02.xlsx
move /Y kc1prdb01_1* kc1prdb01.xlsx

"C:\Program Files\Microsoft Office\Office14\excel.exe" kc1prdb01.xlsx w_LINUXMACRO.XLSM
"C:\Program Files\Microsoft Office\Office14\excel.exe" kc1prapkc01.xlsx w_LINUXMACRO.XLSM
"C:\Program Files\Microsoft Office\Office14\excel.exe" kc1prapkc02.xlsx w_LINUXMACRO.XLSM
"C:\Program Files\Microsoft Office\Office14\excel.exe" kc2prapkc02.xlsx w_LINUXMACRO.XLSM
"C:\Program Files\Microsoft Office\Office14\excel.exe" kc1prapal01.xlsx w_MACRO.XLSM


"%windir%\system32\WindowsPowerShell\v1.0\PowerShell.exe" -noexit "C:\NMON\refresh_Weekly_new.ps1"