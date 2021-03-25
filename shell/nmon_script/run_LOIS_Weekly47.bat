cd C:\NMON\out

copy w_control_wes01.txt w_control.txt
"C:\Program Files\Microsoft Office\Office14\excel.exe" "aNmonW47.xlsm"
copy w_control_wes02.txt w_control.txt
"C:\Program Files\Microsoft Office\Office14\excel.exe" "aNmonW47.xlsm"
copy w_control_ihs01.txt w_control.txt
"C:\Program Files\Microsoft Office\Office14\excel.exe" "aNmonW47.xlsm"
copy w_control_ihs02.txt w_control.txt
"C:\Program Files\Microsoft Office\Office14\excel.exe" "aNmonW47.xlsm"
copy w_control_was01.txt w_control.txt
"C:\Program Files\Microsoft Office\Office14\excel.exe" "aNmonW47.xlsm"
copy w_control_was02.txt w_control.txt
"C:\Program Files\Microsoft Office\Office14\excel.exe" "aNmonW47.xlsm"
copy w_control_icm01.txt w_control.txt
"C:\Program Files\Microsoft Office\Office14\excel.exe" "aNmonW47.xlsm"
copy w_control_icm02.txt w_control.txt
"C:\Program Files\Microsoft Office\Office14\excel.exe" "aNmonW47.xlsm"
copy w_control_tsm01.txt w_control.txt
"C:\Program Files\Microsoft Office\Office14\excel.exe" "aNmonW47.xlsm"
copy w_control_ipm02.txt w_control.txt
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
