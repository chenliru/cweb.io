cd C:\NMON\out

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
