cd C:\NMON\out

copy w_control_kc1prapal01.txt w_control.txt
"C:\Program Files\Microsoft Office\Office14\excel.exe" "aNmonW47.xlsm"
copy w_control_kc1prapkc01.txt w_control.txt
"C:\Program Files\Microsoft Office\Office14\excel.exe" "aNmonW47.xlsm"
copy w_control_kc1prapkc02.txt w_control.txt
"C:\Program Files\Microsoft Office\Office14\excel.exe" "aNmonW47.xlsm"
copy w_control_kc2prapkc02.txt w_control.txt
"C:\Program Files\Microsoft Office\Office14\excel.exe" "aNmonW47.xlsm"
copy w_control_kc1prdb01.txt w_control.txt
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
